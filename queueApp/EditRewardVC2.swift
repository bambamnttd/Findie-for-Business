//
//  EditRewardVC2.swift
//  queueApp
//
//  Created by Bambam on 13/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class EditRewardVC2: UIViewController {
    
    @IBOutlet weak var proNameTextField: UITextField!
    @IBOutlet weak var pointTextField: UITextField!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var cafe_id = String()
    var rewardData : RewardData!
    var oldproname = UILabel()
    var oldpoint = UILabel()
    var oldimage = UIImage()
    let db = Firestore.firestore()
    var vSpinner : UIView?
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    var user = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupBackButtonNavBar()
        setImage()
        
        saveButton.layer.cornerRadius = 15
        
        proNameTextField.setBackground()
        pointTextField.setBackground()
        
        
        if user == "old" {
            showData()
            saveButton.addTarget(self, action: #selector(updateData), for: .touchUpInside)
            saveButton.isHidden = false
            titleLabel.text = "แก้ไขของรางวัล"
        } else if user == "new" {
            proImage.image = UIImage(named: "background.png")
            setNextButton()
            saveButton.isHidden = true
            titleLabel.text = "สร้างของรางวัล"
        } else {
            saveButton.isHidden = false
            saveButton.addTarget(self, action: #selector(addData), for: .touchUpInside)
            titleLabel.text = "สร้างของรางวัล"
        }
    }
    
    func setNextButton() {
        let nextButton = UIButton()
        nextButton.setTitleColor(red, for: .normal)
        nextButton.setTitle("ต่อไป", for: .normal)
        nextButton.addTarget(self, action: #selector(openConditionVC), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: nextButton)
        navigationItem.rightBarButtonItem = menuBarItem
    }
    
    func setImage() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        proImage.isUserInteractionEnabled = true
        proImage.addGestureRecognizer(imageTap)
    }
    
    @objc func openConditionVC() {
        if proNameTextField.text != "" && pointTextField.text != "" {
            let reward = proNameTextField.text!
            let pointString = pointTextField.text!
            let rewardData = AddRewardData(cafe_id: cafe_id, point: Int(pointString)!, reward: reward, proImage: proImage.image!)
            let conditionVC = self.storyboard?.instantiateViewController(withIdentifier: "ConditionVC") as! ConditionVC
            conditionVC.data = rewardData
            conditionVC.cafe_id = cafe_id
            self.navigationController?.pushViewController(conditionVC, animated: true)
        }
    }
    
    func showData() {
        proNameTextField.text = rewardData.reward
        pointTextField.text = "\(rewardData.point)"
        if rewardData.reward_imageURL == "" {
            proImage.image = UIImage(named: "background.png")
        } else {
            proImage.setImage(rewardData.reward_imageURL)
        }
        oldimage = proImage.image!
    }
    
    @objc func updateData() {
        if proNameTextField.text != "" && pointTextField.text != "" {
            if proImage.image != UIImage(named: "background.png") {
                if proImage.image != oldimage { //ถ้ารูปไม่ใช่รูปเดิม
                    ///upload user image to storage and get url
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
                                
                            let reward_imageURL = url.absoluteString
                            let oldData = [
                                "reward": self.rewardData.reward,
                                "point": self.rewardData.point,
                                "reward_imageURL": self.rewardData.reward_imageURL
                                ] as [String : Any]
                            let newData = [
                                "reward": self.proNameTextField.text!,
                                "point": Int(self.pointTextField.text!),
                                "reward_imageURL": reward_imageURL
                                ] as [String : Any]
                            let rewardRef = self.db.collection("cafe_reward").document(self.cafe_id)
                                
                            //ลบข้อมูลเก่าออกก่อน
                            rewardRef.updateData([
                                "reward": FieldValue.arrayRemove([oldData]),
                            ]) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                } else {
                                    print("Delete old data successfully")
                                        
                                    //อัพเดทอันใหม่เข้าไป
                                    rewardRef.updateData([
                                        "reward": FieldValue.arrayUnion([newData]),
                                    ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                        } else {
                                            print("Document successfully updated")
                                            let imageRef = Storage.storage().reference(forURL: self.rewardData.reward_imageURL)
                                                // Delete the file
                                            imageRef.delete { error in
                                                if let error = error {
                                                    print("ลบรูปไม่ได้")
                                                } else {
                                                    print("ลบรูปเรียบร้อย")
                                                    self.removeLoading()
                                                    let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                                        self.performSegueToReturnBack()
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
                } else { //รูปเดิม
                    loading(self.view)
                    let oldData = [
                        "reward": rewardData.reward,
                        "point": rewardData.point,
                        "reward_imageURL": rewardData.reward_imageURL
                        ] as [String : Any]
                    let newData = [
                        "reward": proNameTextField.text!,
                        "point": Int(pointTextField.text!),
                        "reward_imageURL": rewardData.reward_imageURL
                        ] as [String : Any]
                    let rewardRef = db.collection("cafe_reward").document(cafe_id)
                        
                    //ลบข้อมูลเก่าออกก่อน
                    rewardRef.updateData([
                        "reward": FieldValue.arrayRemove([oldData]),
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Delete old data successfully")
                                
                            //อัพเดทอันใหม่เข้าไป
                            rewardRef.updateData([
                                "reward": FieldValue.arrayUnion([newData]),
                            ]) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                } else {
                                    print("Document successfully updated")
                                    self.removeLoading()
                                    let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                        self.performSegueToReturnBack()
                                    }))
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func addData() {
        if proNameTextField.text != "" && pointTextField.text != "" {
            if proImage.image != UIImage(named: "background.png") {
                ///upload user image to storage and get url
                self.loading(self.view)
                guard let image = proImage.image, let data = image.jpegData(compressionQuality: 1.0) else {
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
                    } else {
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
                                
                        let reward_imageURL = url.absoluteString
                        let newData = [
                            "reward": self.proNameTextField.text!,
                            "point": Int(self.pointTextField.text!),
                            "reward_imageURL": reward_imageURL
                            ] as [String : Any]
                        let rewardRef = self.db.collection("cafe_reward").document(self.cafe_id)
                        rewardRef.updateData([
                            "reward": FieldValue.arrayUnion([newData]),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                self.removeLoading()
                                let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                    self.performSegueToReturnBack()
                                }))
                                self.present(alert, animated: true)
                            }
                        }
                    })
                }
            } else { //ไม่มีรูป
                loading(self.view)
                let newData = [
                    "reward": proNameTextField.text!,
                    "point": Int(pointTextField.text!),
                    "reward_imageURL": ""
                    ] as [String : Any]
                let rewardRef = db.collection("cafe_reward").document(cafe_id)
                rewardRef.updateData([
                    "reward": FieldValue.arrayUnion([newData]),
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.removeLoading()
                        let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                            self.performSegueToReturnBack()
                        }))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }

}

extension EditRewardVC2: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditRewardVC2 {
    
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




