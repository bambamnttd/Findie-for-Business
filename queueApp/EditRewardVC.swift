//
//  EditRewardVC.swift
//  queueApp
//
//  Created by Bambam on 4/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

struct RewardData {
    var point: Int
    var reward: String
    var reward_imageURL: String
}

struct AddRewardData {
    var cafe_id: String
    var point: Int
    var reward: String
    var proImage: UIImage
}

class EditRewardVC: UIViewController {
    
    @IBOutlet weak var proNameTextField: UITextField!
    @IBOutlet weak var pointTextField: UITextField!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var table: UITableView!
    
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let db = Firestore.firestore()
    var rewardArray = [RewardData]()
    var cafe_id = String()
    var user = ""
    var addArray = [AddRewardData]()
    var register = false

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupBackButtonNavBar()
        setUI()
        setImage()
        getData()
        setNextButton()
        table.delegate = self
        table.dataSource = self
        addButton.addTarget(self, action: #selector(addData), for: .touchUpInside)
    }
    
    func setUI() {
        proNameTextField.setBackground()
        pointTextField.setBackground()
        addButton.layer.cornerRadius = 15
        proImage.image = UIImage(named: "background.png")
    }
    
    func setNextButton() {
        let nextButton = UIButton()
        nextButton.setTitleColor(red, for: .normal)
        nextButton.setTitle("ต่อไป", for: .normal)
        nextButton.addTarget(self, action: #selector(openConditionVC), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: nextButton)
        navigationItem.rightBarButtonItem = menuBarItem
    }
    
    @objc func openConditionVC() {
        if addArray.count != 0 {
            let conditionVC = self.storyboard?.instantiateViewController(withIdentifier: "ConditionVC") as! ConditionVC
//            conditionVC.data = addArray
            print(cafe_id)
            conditionVC.cafe_id = cafe_id
            self.navigationController?.pushViewController(conditionVC, animated: true)
        }
    }
    
    @objc func addData() {
        if user == "new" {
            if proNameTextField.text != "" && pointTextField.text != "" {
                let reward = proNameTextField.text!
                let pointString = pointTextField.text!
                self.addArray.append(AddRewardData(cafe_id: cafe_id, point: Int(pointString)!, reward: reward, proImage: proImage.image!))
                proImage.image = UIImage(named: "background.png")
                proNameTextField.text = ""
                pointTextField.text = ""
                table.reloadData()
            }
        }
    }
    
    func setImage() {
        let imageTap1 = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        proImage.isUserInteractionEnabled = true
        proImage.addGestureRecognizer(imageTap1)
    }
    
    func getData() {
        if user != "new" {
            db.collection("cafe_reward").document(cafe_id).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let rewardArray1 = document.get("reward") as! [[String:Any]]
                self.rewardArray.removeAll()
                for re in rewardArray1 {
                    let point = re["point"] as! Int
                    let reward = re["reward"] as! String
                    let reward_imageURL = re["reward_imageURL"] as! String
                    self.rewardArray.append(RewardData(point: point, reward: reward, reward_imageURL: reward_imageURL))
                }
                print(self.rewardArray.count)
                self.table.reloadData()
            }
        }
        
    }
}

extension EditRewardVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user == "new" {
            return addArray.count
        }
        return rewardArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "RewardCell", for: indexPath) as? RewardCell else {
            return UITableViewCell()
        }
        if user == "new" {
            cell.rewardLabel.text = addArray[indexPath.row].reward
            cell.rewardImage.image = addArray[indexPath.row].proImage
            cell.pointLabel.text = "\(addArray[indexPath.row].point) แต้ม"
        }
        else {
            cell.rewardLabel.text = rewardArray[indexPath.row].reward
            cell.pointLabel.text = "\(rewardArray[indexPath.row].point) แต้ม"
            if rewardArray[indexPath.row].reward_imageURL != "" {
                cell.rewardImage.setImage(rewardArray[indexPath.row].reward_imageURL)
            }
            else {
                cell.rewardImage.image = UIImage(named: "background.png")
            }
        }
        return cell
    }
    
    
}

extension EditRewardVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
