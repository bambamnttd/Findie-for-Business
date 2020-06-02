//
//  AddImageVC.swift
//  queueApp
//
//  Created by Bambam on 6/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class AddImageVC: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    var cafe_id = String()
    let db = Firestore.firestore()
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    var tap = ""
    var vSpinner: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        image.image = UIImage(named: "addImage.png")
        setPostButton()
        showImagePickerController()
        setImage()
        setGoback()
    }
    
    func setImage() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(imageTap)
    }
    
    func setGoback() {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back_red.png"), for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 28)
            
        let menuBarItem = UIBarButtonItem(customView: backButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 40)
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        currHeight?.isActive = true
        
        navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setPostButton() {
        let postButton = UIButton()
        postButton.setTitleColor(red, for: .normal)
        postButton.setTitle("แชร์", for: .normal)
        postButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: postButton)
        navigationItem.rightBarButtonItem = menuBarItem
    }
    
    @objc func addImage() {
        if image.image != UIImage(named: "addImage.png") {
        ///upload user image to storage and get url
            self.loading(self.view)
            guard let image = image.image,
                let data = image.jpegData(compressionQuality: 1.0) else {
                    print("error")
                    return
            }
            let cafeImageRef = db.collection("cafe_image").document(cafe_id)
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

                    let imageURL = url.absoluteString
                    var imageData = [String: FieldValue]()
                    if self.tap == "image" {
                        imageData = ["cafe_image": FieldValue.arrayUnion([imageURL])]
                    } else {
                        imageData = ["cafe_menu": FieldValue.arrayUnion([imageURL])]
                    }
                    cafeImageRef.updateData(imageData) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            let alert = UIAlertController(title: "แชร์แล้วเรียบร้อย", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                })
            }
        }
    }
}

extension AddImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func openImagePicker(_ sender:Any) {
        showImagePickerController()
    }
    
    func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            image.image = editedImage
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            image.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}

extension AddImageVC {
    
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


