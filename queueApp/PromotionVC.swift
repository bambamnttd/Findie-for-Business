//
//  PromotionVC.swift
//  queueApp
//
//  Created by Bambam on 30/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class PromotionVC: UIViewController {
    @IBOutlet weak var pronameTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var startdateTextField: UITextField!
    @IBOutlet weak var enddateTextField: UITextField!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var createButton: UIButton!
    private var datePicker : UIDatePicker?
    private var datePicker2 : UIDatePicker?
    
    var cafe_id = String()
    let db = Firestore.firestore()
    var getStartdate = Date()
    var getEnddate = Date()
    var user = ""
    var vSpinner: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupBackButtonNavBar()
        setPickerView()
        setUI()
        setImage()
    }
    
    func setUI() {
        detailTextView.layer.borderColor = UIColor.lightGray.cgColor
        detailTextView.layer.borderWidth = 1
        detailTextView.layer.cornerRadius = 10
        pronameTextField.setBackground()
        startdateTextField.setBackground()
        enddateTextField.setBackground()
        proImage.image = UIImage(named: "background.png")
        createButton.layer.cornerRadius = 15
        createButton.addTarget(self, action: #selector(createPromotion), for: .touchUpInside)
    }
    
    func setPickerView() {
        datePicker = UIDatePicker()
        datePicker?.tag = 1
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        startdateTextField.inputView = datePicker
        
        datePicker2 = UIDatePicker()
        datePicker2?.tag = 2
        datePicker2?.datePickerMode = .date
        datePicker2?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        enddateTextField.inputView = datePicker2
    }
    
    func setImage() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        proImage.isUserInteractionEnabled = true
        proImage.addGestureRecognizer(imageTap)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        if datePicker.tag == 1 {
            startdateTextField.text = dateFormatter.string(from: datePicker.date)
            getStartdate = datePicker.date
        } else {
            enddateTextField.text = dateFormatter.string(from: datePicker.date)
            getEnddate = datePicker.date
        }
    }
    
    func checkTextViewNotEmpty(_ textView: UITextView) {
        if textView.text == "" {
            textView.layer.borderColor = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1).cgColor
        }
        else {
            textView.layer.borderColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
        }
    }
    
    func checkImageViewNotEmpty(_ imageView: UIImageView) {
        if imageView.image == UIImage(named: "background.png") {
            imageView.layer.borderColor = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1).cgColor
            imageView.layer.borderWidth = 1
        }
        else {
            imageView.layer.borderWidth = 0
        }
    }
    
    @objc func createPromotion() {
        pronameTextField.checkTextFieldNotEmpty()
        startdateTextField.checkTextFieldNotEmpty()
        enddateTextField.checkTextFieldNotEmpty()
        checkTextViewNotEmpty(detailTextView)
        checkImageViewNotEmpty(proImage)
        if pronameTextField.text != "" && detailTextView.text != "" && startdateTextField.text != "" && enddateTextField.text != "" {
            let proname = pronameTextField.text!
            let detail = detailTextView.text!
            if proImage.image != UIImage(named: "background.png") {
            ///upload user image to storage and get url
                print("รูปไม่ซ้ำ")
                self.loading(self.view)
                guard let image = proImage.image,
                    let data = image.jpegData(compressionQuality: 1.0) else {
                        print("error")
                        return
                }
                let imageName = UUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let imageReference = Storage.storage().reference().child(cafe_id).child("\(imageName).jpeg")

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
                        let now = Date()
                        var ref: DocumentReference? = nil
                        ref = self.db.collection("promotion").addDocument(data: [
                            "cafe_id": self.cafe_id,
                            "promotion_topic": proname,
                            "promotion_detail": detail,
                            "promotion_imageURL": logoURL,
                            "startdate": self.getStartdate,
                            "enddate": self.getEnddate,
                            "createdate": now
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added with ID: \(ref!.documentID)")
                                let proRef = self.db.collection("promotion").document(ref!.documentID)
                                proRef.updateData([
                                    "promotion_id": ref!.documentID
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                        self.db.collection("cafe").document(self.cafe_id).updateData([
                                            "promotion": true
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                            } else {
                                                print("Document successfully updated")
                                                self.removeLoading()
                                            let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                                if self.user == "new" {
                                                    let showPromotionVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowPromotionVC") as! ShowPromotionVC
                                                    showPromotionVC.cafe_id = self.cafe_id
                                                    showPromotionVC.user = "new"
                                                    self.navigationController?.pushViewController(showPromotionVC, animated: true)
                                                } else {
                                                    self.performSegueToReturnBack()
                                                }
                                            }))
                                            self.present(alert, animated: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
}

extension PromotionVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func openImagePicker(_ sender:Any) {
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
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            proImage.image = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            proImage.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}

extension PromotionVC {
    
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



