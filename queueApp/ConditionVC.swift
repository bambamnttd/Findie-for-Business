//
//  ConditionVC.swift
//  queueApp
//
//  Created by Bambam on 4/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

class ConditionVC: UIViewController {
    
    @IBOutlet weak var conTF1: UITextField!
    @IBOutlet weak var conTF2: UITextField!
    @IBOutlet weak var conTF3: UITextField!
    @IBOutlet weak var expdateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearExpdateButton: UIButton!
    
    private var datePicker : UIDatePicker?
    
    var data : AddRewardData!
    let db = Firestore.firestore()
    var addArray = [[String: Any]]()
    var cafe_id = String()
    var getdate = Date()
    var delegate : RegisterDelegate?
    var from = ""
    var oldexpdate = UILabel()
    var vSpinner: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupBackButtonNavBar()
        setPickerView()
        setUI()
        print(data)
    }
    
    func setUI() {
        conTF1.setBackground()
        conTF2.setBackground()
        conTF3.setBackground()
        expdateTextField.setBackground()
        saveButton.layer.cornerRadius = 15
        clearExpdateButton.addTarget(self, action: #selector(clearExpdate), for: .touchUpInside)
        if from == "ShowRewardVC" {
            showCondition()
            saveButton.addTarget(self, action: #selector(updateData), for: .touchUpInside)
        } else {
            saveButton.addTarget(self, action: #selector(addData), for: .touchUpInside)
        }
    }
    
    @objc func clearExpdate() {
        expdateTextField.text = ""
    }
    
    func showCondition() {
        db.collection("cafe_reward").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let conditionArray = document.get("conditions") as! [String]
                if conditionArray.count == 1 {
                    self.conTF1.text = conditionArray[0]
                } else if conditionArray.count == 2 {
                    self.conTF1.text = conditionArray[0]
                    self.conTF2.text = conditionArray[1]
                } else if conditionArray.count == 3 {
                    self.conTF1.text = conditionArray[0]
                    self.conTF2.text = conditionArray[1]
                    self.conTF3.text = conditionArray[2]
                } else {
                    self.conTF1.text = ""
                    self.conTF2.text = ""
                    self.conTF3.text = ""
                }
                if document.get("exp_date") != nil {
                    let expdate = document.get("exp_date") as! Timestamp
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yy"
                    self.expdateTextField.text = dateFormatter.string(from: expdate.dateValue())
                    self.oldexpdate.text = dateFormatter.string(from: expdate.dateValue())
                } else {
                    self.expdateTextField.text = ""
                }
            } else {
                print("ไม่มีข้อมูล")
            }
        }
    }
    
    @objc func updateData() {
        var conArray = [String]()
        var data = [String: Any]()
        if conTF1.text != "" {
            conArray.append(conTF1.text!)
        }
        if conTF2.text != "" {
            conArray.append(conTF2.text!)
        }
        if conTF3.text != "" {
            conArray.append(conTF3.text!)
        }
        if expdateTextField.text != "" {
            if expdateTextField.text == oldexpdate.text {
                data = [
                    "conditions": conArray
                ]
            } else {
                data = [
                    "conditions": conArray,
                    "exp_date": getdate
                ]
            }
        } else {
            data = [
                "conditions": conArray,
                "exp_date": FieldValue.delete()
            ]
        }
        db.collection("cafe_reward").document(cafe_id).updateData(data) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                let alert = UIAlertController(title: "บันทึกเรียบร้อย", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                    self.performSegueToReturnBack()
                }))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc func addData() {
        print(getdate)
        let con1 = conTF1.text ?? ""
        let con2 = conTF2.text ?? ""
        let con3 = conTF3.text ?? ""
        let expdate = expdateTextField.text ?? ""
        var conArray = [String]()
        
        if con1 != "" {
            conArray.append(con1)
        }
        if con2 != "" {
            conArray.append(con2)
        }
        if con3 != "" {
            conArray.append(con3)
        }
        
        var reward1 = [String : Any]()
        
        if data.proImage != UIImage(named: "background") {
            self.loading(self.view)
            let mm : UIImage? = data.proImage
            guard let image = mm,
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
                    let reward1 = [
                            "reward": self.data.reward,
                            "point": self.data.point,
                            "reward_imageURL": reward_imageURL
                        ] as [String : Any]
                    
                    var data = [String: Any]()
                    if expdate == "" {
                        data = [
                            "cafe_id": self.cafe_id,
                            "reward": [reward1],
                            "conditions": conArray
                        ]
                    } else {
                        data = [
                            "cafe_id": self.cafe_id,
                            "reward": [reward1],
                            "conditions": conArray,
                            "exp_date": self.getdate
                        ]
                    }
                    let rewardRef = self.db.collection("cafe_reward").document(self.cafe_id)
                    rewardRef.setData(data) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                            self.db.collection("cafe").document(self.cafe_id).updateData([
                                "membercard": true
                            ]) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                } else {
                                    print("Document successfully updated")
                                    self.removeLoading()
                                    let alert = UIAlertController(title: "บันทึกเรียบร้อย", message: nil, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                        let showRewardVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowRewardVC") as! ShowRewardVC
                                        showRewardVC.cafe_id = self.cafe_id
                                        showRewardVC.user = "new"
                                        self.navigationController?.pushViewController(showRewardVC, animated: true)
                                    }))
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                })
            }
        } else { //ไม่มีรูปใส่เข้าไป
            let reward1 = [
                    "reward": data.reward,
                    "point": data.point,
                    "reward_imageURL": ""
                ] as [String : Any]
            
            var data = [String: Any]()
            if expdate == "" {
                data = [
                    "cafe_id": cafe_id,
                    "reward": [reward1],
                    "conditions": conArray
                ]
            } else {
                data = [
                    "cafe_id": cafe_id,
                    "reward": reward1,
                    "conditions": conArray,
                    "exp_date": getdate
                ]
            }
            loading(self.view)
            let rewardRef = self.db.collection("cafe_reward").document(cafe_id)
            rewardRef.setData(data) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.db.collection("cafe").document(self.cafe_id).updateData([
                        "membercard": true
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            let alert = UIAlertController(title: "บันทึกเรียบร้อย", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                let showRewardVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowRewardVC") as! ShowRewardVC
                                showRewardVC.cafe_id = self.cafe_id
                                showRewardVC.user = "new"
                                self.navigationController?.pushViewController(showRewardVC, animated: true)
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }

        }
    }
    
    func setPickerView() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        expdateTextField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        expdateTextField.text = dateFormatter.string(from: datePicker.date)
        getdate = datePicker.date
//        view.endEditing(true)
    }
}

extension ConditionVC {
    
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
