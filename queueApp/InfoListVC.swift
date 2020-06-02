//
//  InfoListVC.swift
//  queueApp
//
//  Created by Bambam on 30/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import UIImageColors

class InfoListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    
    var iconArray = [String]()
    var topicArray = [String]()
    var cafe_id = String()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var from = ""
    var logoURL = UILabel()
    var coverURL = UILabel()
    var vSpinner : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButtonNavBar()
        setImage()
        showImage()
        menuTable.dataSource = self
        menuTable.delegate = self
        logoImage.image = UIImage(named: "background.png")
        coverImage.image = UIImage(named: "background.png")
        
//        iconArray = ["information.png", "contact.png", "time.png"]
        iconArray = ["information.png", "contact.png", "time.png", "facility.png"]
//        topicArray = ["ข้อมูลพื้นฐาน", "ที่อยู่ ช่องทางติดต่อ", "เวลาเปิด - ปิด"]
        topicArray = ["ข้อมูลพื้นฐาน", "ที่อยู่ ช่องทางติดต่อ", "เวลาเปิด - ปิด", "สิ่งอำนวยความสะดวก"]
    }
    
    func showImage() {
        db.collection("cafe_image").document(cafe_id).addSnapshotListener { documentSnapshot, err in
            guard let docc = documentSnapshot else {
                print("Error fetching document: \(err!)")
                return
            }
            let cover = docc.get("cafe_cover") as! String
            if cover == "" {
                self.coverImage.image = UIImage(named: "background.png")
            } else {
                self.coverImage.setImage(cover)
                self.coverURL.text = cover
            }
            
            let logo = docc.get("cafe_logo") as! String
            if logo == "" {
                self.logoImage.image = UIImage(named: "background.png")
            } else {
                self.logoImage.setImage(logo)
                self.logoURL.text = logo
            }
        }
    }
    
    func setImage() {
        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.4
        darkView.frame = coverImage.bounds
        coverImage.addSubview(darkView)
        logoImage.layer.cornerRadius = logoImage.bounds.height / 2
        
        let imageTap1 = UITapGestureRecognizer(target: self, action: #selector(openCoverPicker))
        coverImage.isUserInteractionEnabled = true
        coverImage.addGestureRecognizer(imageTap1)
        
        let imageTap2 = UITapGestureRecognizer(target: self, action: #selector(openLogoPicker))
        logoImage.isUserInteractionEnabled = true
        logoImage.addGestureRecognizer(imageTap2)
        
    }
    
    func addLogo() {
        if logoImage.image != UIImage(named: "background.png") {
            ///upload user image to storage and get url
            print("รูปไม่ซ้ำ")
            
            guard let image = logoImage.image,let data = image.jpegData(compressionQuality: 1.0) else {
                print("error")
                return
            }
            let cafeImageRef = db.collection("cafe_image").document(cafe_id)
            let imageName = UUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let imageReference = Storage.storage().reference().child(cafe_id).child("\(imageName).jpeg")
            loading(self.view)
            //upload image to storage
            imageReference.putData(data, metadata: metadata) { (metadata, err) in
                if let err = err {
                    print("error")
                    return
                }
                else {
                    print("อัพรูป")
                }
                //get URL of image from storage
                imageReference.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("error")
                        return
                    }
                    guard let url = url else {
                        print("error")
                        return
                    }
                    let logoURL = url.absoluteString
                    cafeImageRef.updateData([
                        "cafe_logo": logoURL
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            let alert = UIAlertController(title: "เปลี่ยนรูปเรียบร้อย", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                })
            }
        }
    }
    
    func addCover() {
        if coverImage.image != UIImage(named: "background.png") {
            ///upload user image to storage and get url
            print("รูปไม่ซ้ำ")
            let colors = coverImage.image!.getColors()
            let primaryColor = colors!.primary
            let (red, green, blue, alpha) = primaryColor!.rgb()!
            print(red, green, blue)
            guard let image = coverImage.image,let data = image.jpegData(compressionQuality: 1.0) else {
                print("error")
                return
            }
            let cafeImageRef = db.collection("cafe_image").document(cafe_id)
            let imageName = UUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let imageReference = Storage.storage().reference().child(cafe_id).child("\(imageName).jpeg")
            loading(self.view)
            //upload image to storage
            imageReference.putData(data, metadata: metadata) { (metadata, err) in
                if let err = err {
                    print("error")
                    return
                }
                else {
                    print("อัพรูป")
                }
                //get URL of image from storage
                imageReference.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("error")
                        return
                    }
                    guard let url = url else {
                        print("error")
                        return
                    }
                    let logoURL = url.absoluteString
                    cafeImageRef.updateData([
                        "cafe_cover": logoURL,
                        "cafe_color": ["red": red, "green": green, "blue": blue]
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            let alert = UIAlertController(title: "เปลี่ยนรูปเรียบร้อย", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = menuTable.dequeueReusableCell(withIdentifier: "InfoListCell", for: indexPath) as? InfoListCell else {
            return UITableViewCell()
        }
        cell.iconImage.image = UIImage(named: iconArray[indexPath.row])
        cell.topicLabel.text = topicArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoVC") as! InfoVC
            infoVC.cafe_id = cafe_id
            self.navigationController?.pushViewController(infoVC, animated: true)
        }
        else if indexPath.row == 1 {
            let contactVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactVC") as! ContactVC
            contactVC.cafe_id = cafe_id
            self.navigationController?.pushViewController(contactVC, animated: true)
        }
        else if indexPath.row == 2 {
            let timeVC = self.storyboard?.instantiateViewController(withIdentifier: "TimeVC") as! TimeVC
            timeVC.cafe_id = cafe_id
            timeVC.from = "infolist"
            self.navigationController?.pushViewController(timeVC, animated: true)
        }
        else if indexPath.row == 3 {
            let facilityVC = self.storyboard?.instantiateViewController(withIdentifier: "FacilityVC") as! FacilityVC
            facilityVC.cafe_id = cafe_id
            self.navigationController?.pushViewController(facilityVC, animated: true)
        }
    }
}

extension InfoListVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func openCoverPicker(_ sender:Any) {
        from = "cover"
        showImagePickerController()
    }
    
    @objc func openLogoPicker(_ sender:Any) {
        from = "logo"
        showImagePickerController()
    }
    
    func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if from == "logo" {
            print("logo")
            //ลบรูปออกจาก storage
            if logoImage.image != UIImage(named: "background.png") {
                let imageRef = self.storage.reference(forURL: logoURL.text!)
                imageRef.delete { error in
                    if let error = error {
                        print("error")
                    } else {
                        print("Delete image successfully")
                    }
                }
            }
            if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                logoImage.image = editedImage
            } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                logoImage.image = originalImage
            }
            addLogo()
            dismiss(animated: true, completion: nil)
        } else {
            print("cover")
            //ลบรูปออกจาก storage
            if coverImage.image != UIImage(named: "background.png") {
                let imageRef = self.storage.reference(forURL: logoURL.text!)
                imageRef.delete { error in
                    if let error = error {
                        print("error")
                    } else {
                        print("Delete image successfully")
                    }
                }
            }
            if let editedImage = info[.editedImage] as? UIImage {
                coverImage.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                coverImage.image = originalImage
            }
            addCover()
            dismiss(animated: true, completion: nil)
        }
    }
}

extension InfoListVC {
    func loading(_ uiView: UIView) {
        var loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 241/255, alpha: 1)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        var activity: UIActivityIndicatorView = UIActivityIndicatorView()
        activity.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activity.style = UIActivityIndicatorView.Style.large
        activity.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        DispatchQueue.main.async {
            loadingView.addSubview(activity)
            uiView.addSubview(loadingView)
        }
        vSpinner = loadingView
        activity.startAnimating()
    }
    
    func removeLoading() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}




