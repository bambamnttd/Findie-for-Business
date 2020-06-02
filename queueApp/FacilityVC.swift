//
//  FacilityVC.swift
//  queueApp
//
//  Created by Bambam on 7/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

struct FacilityData {
    var topic: String
    var bool: Bool
}

extension FacilityVC: SelectedDelegate {
    func selected(topic: String, bool: Bool) {
        if topic == "wifi" {
            wifi = bool
        } else if topic == "carpark" {
            carpark = bool
        } else if topic == "creditcard" {
            creditcard = bool
        } else if topic == "onlinePayment" {
            onlinePayment = bool
        } else {
            delivery = bool
        }
    }
}

class FacilityVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var seatTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!

    var facility = [String]()
    var myfacility = [FacilityData]()
    let db = Firestore.firestore()
    var cafe_id = String()
    var wifi = Bool()
    var carpark = Bool()
    var delivery = Bool()
    var onlinePayment = Bool()
    var creditcard = Bool()
    var seatOptions = [String]()
    let lightgray = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupBackButtonNavBar()
        seatTextField.setBackground()
        table.dataSource = self
        table.delegate = self
        addButton.layer.cornerRadius = 15
        addButton.addTarget(self, action: #selector(addData), for: .touchUpInside)
        facility = ["มี WiFi หรือไม่?", "มีที่จอดรถหรือไม่?", "มีช่องทางชำระเงินออนไลน์หรือไม่?", "รับบัตรเครดิตหรือไม่?", "มี Delivery หรือไม่?"]
        seatOptions = ["ไม่มีที่นั่ง","ไม่เกิน 10 ที่นั่ง","11 - 40 ที่นั่ง","41 - 80 ที่นั่ง","มากกว่า 80 ที่นั่ง"]
        setPickerView()
        getFacilityData()
    }
    
    func setPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.backgroundColor = lightgray
        seatTextField.inputView = pickerView
    }
    
    @objc func addData() {
        print(wifi)
        print(carpark)
        print(onlinePayment)
        print(creditcard)
        print(delivery)
        if seatTextField.text != "" {
            let data = [
                "table_amount": seatTextField.text,
                "wifi": wifi,
                "carpark": carpark,
                "onlinePayment": onlinePayment,
                "creditcard":creditcard,
                "delivery": delivery
                ] as [String : Any]
            db.collection("cafe").document(cafe_id).updateData(data) { err in
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
    
    func getFacilityData() {
        db.collection("cafe").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let table_amount = document.get("table_amount") as! String
                self.seatTextField.text = table_amount
                
                let wifi1 = document.get("wifi") as! Bool
                self.wifi = wifi1
                self.myfacility.append(FacilityData(topic: "wifi", bool: wifi1))
                print("wifi = \(wifi1)")
                
                let carpark1 = document.get("carpark") as! Bool
                self.carpark = carpark1
                self.myfacility.append(FacilityData(topic: "carpark", bool: carpark1))
                print("carpark = \(carpark1)")
                
                let onlinePayment1 = document.get("onlinePayment") as! Bool
                self.onlinePayment = onlinePayment1
                self.myfacility.append(FacilityData(topic: "onlinePayment", bool: onlinePayment1))
                print("creditcard = \(onlinePayment1)")
                
                let creditcard1 = document.get("creditcard") as! Bool
                self.creditcard = creditcard1
                self.myfacility.append(FacilityData(topic: "creditcard", bool: creditcard1))
                print("creditcard = \(creditcard1)")
                
                
                let delivery1 = document.get("delivery") as! Bool
                self.delivery = delivery1
                self.myfacility.append(FacilityData(topic: "delivery", bool: delivery1))
                print("delivery = \(delivery1)")
                
                self.table.reloadData()
            }
        }
    }
}

extension FacilityVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myfacility.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "FacilityCell", for: indexPath) as? FacilityCell else {
            return UITableViewCell()
        }
        cell.facilityLabel.text = facility[indexPath.row]
        print(myfacility)
        cell.data = myfacility[indexPath.row]
        cell.delegate = self
        if myfacility[indexPath.row].bool == true {
            cell.yesImage.image = UIImage(named: "check.png")
            cell.noImage.image = UIImage(named: "uncheck.png")
        } else {
            cell.yesImage.image = UIImage(named: "uncheck.png")
            cell.noImage.image = UIImage(named: "check.png")
        }
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 4 {
            cell.yesLabel.text = "มี"
            cell.noLabel.text = "ไม่มี"

        } else if indexPath.row == 3 {
            cell.yesLabel.text = "รับ"
            cell.noLabel.text = "ไม่รับ"
        }
        
        return cell
    }
}

extension FacilityVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seatOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return seatOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        seatTextField.text = seatOptions[row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
