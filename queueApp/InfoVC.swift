//
//  InfoVC.swift
//  queueApp
//
//  Created by Bambam on 2/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class InfoVC: UIViewController {
    
    @IBOutlet weak var nameTextFieldTH: UITextField!
    @IBOutlet weak var nameTextFieldEN: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var typeTable: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editTypeButton: UIButton!
    
    let db = Firestore.firestore()
    var cafe_id = String()
    var mytypeArray = [String]()
    var typeArray = [String]()
    var priceArray = [String]()
    let lightgray = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    var typeSelectData = [String]()
    var click = 0
    var checkImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButtonNavBar()
        hideKeyboard()
        setKeyboardUnderTextField()
        setTextField()
        setPickerView()
        typeTable.delegate = self
        typeTable.dataSource = self
        typeTable.allowsMultipleSelection = true
        saveButton.layer.cornerRadius = 15
        editTypeButton.addTarget(self, action: #selector(editType), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(addData), for: .touchUpInside)
        typeArray = ["คาเฟ่", "ร้านอาหาร", "co-working space", "บาร์", "ขนมหวาน", "ขนมไทย", "เบเกอรี่", "เครื่องดื่ม"]
        priceArray = ["น้อยกว่า 100 บาท", "101 - 250 บาท", "251 - 500 บาท", "501 - 1000 บาท" , "มากกว่า 1000 บาท"]
        getData()
    }
    
    func setTextField() {
        nameTextFieldTH.setBackground()
        nameTextFieldEN.setBackground()
        priceTextField.setBackground()
    }
    
    func setPickerView() {
        let pickerView1 = UIPickerView()
        pickerView1.delegate = self
        pickerView1.backgroundColor = lightgray
        pickerView1.tag = 1
        priceTextField.inputView = pickerView1
    }
    
    func getData() {
        db.collection("cafe").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let cafename_en = document.get("cafename_en") as! String
                let cafename_th = document.get("cafename_th") as! String
                let type = document.get("type") as! String
                let typeArray1 = type.components(separatedBy: ", ")
                if document.get("price") != nil {
                    let price = document.get("price") as! String
                    self.priceTextField.text = price
                }
                else {
                    self.priceTextField.text = ""
                }
                self.nameTextFieldEN.text = cafename_en
                self.nameTextFieldTH.text = cafename_th
                self.mytypeArray = typeArray1
            } else {
                print("Document does not exist")
            }
            self.typeTable.reloadData()
        }
    }
    
    @objc func editType() {
        click = 1
        typeTable.reloadData()
        editTypeButton.isHidden = true
    }
    
    @objc func addData() {
        var data = [String: Any]()
        if nameTextFieldEN.text != "" && nameTextFieldTH.text != "" {
            let cafename_en = nameTextFieldEN.text!
            let cafename_th = nameTextFieldTH.text!
            let price = priceTextField.text ?? ""
            if typeSelectData.count > 0 {
                let type = typeSelectData.joined(separator: ", ")
                data = [
                    "cafename_en": cafename_en,
                    "cafename_th": cafename_th,
                    "type": type,
                    "price": price
                ]
            }
            else {
                data = [
                    "cafename_en": cafename_en,
                    "cafename_th": cafename_th,
                    "price": price
                ]
            }
            self.db.collection("cafe").document(cafe_id).updateData(data) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
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

extension InfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = typeTable.dequeueReusableCell(withIdentifier: "TypeCafeCell", for: indexPath) as? TypeCafeCell else {
            return UITableViewCell()
        }
        if click == 1 {
            cell.checkImage.image = UIImage(named: "uncheck.png")
        }
        else {
            for mytype in mytypeArray {
                if typeArray[indexPath.row] == mytype {
                    print("เข้า")
                    print(mytype)
                    cell.checkImage.image = UIImage(named: "check.png")
//                    typeSelectData.append(typeArray[indexPath.row])
                }
            }
        }
        cell.typeLabel.text = typeArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("เลือก")
        if click == 1 {
            let cell = typeTable.cellForRow(at: indexPath) as! TypeCafeCell
            cell.checkImage.image = UIImage(named: "check.png")
            typeSelectData.append(typeArray[indexPath.row])
            print(typeSelectData)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("ไม่เลือก")
        if click == 1 {
            let cell = typeTable.cellForRow(at: indexPath) as! TypeCafeCell
            cell.checkImage.image = UIImage(named: "uncheck.png")
            if let index = typeSelectData.firstIndex(of: typeArray[indexPath.row]) {
                typeSelectData.remove(at: index)
            }
        }
    }
}

extension InfoVC {
    
    func setKeyboardUnderTextField() {
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + 100, right: 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

extension InfoVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priceArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priceArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            priceTextField.text = priceArray[row]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
