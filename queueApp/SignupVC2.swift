//
//  SignupVC2.swift
//  queueApp
//
//  Created by Bambam on 27/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

struct RegisterCafe {
    var cafename_en: String
    var cafename_th: String
    var location: String
    var ll_location: GeoPoint
    var type: String
    var area_en: String
    var area_th: String
}

extension SignupVC2: RegisterDelegate {
    func register(success: Bool) {
        success1 = success
    }
}

class SignupVC2: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    ///cafe info
    @IBOutlet weak var cafenameTextFieldEN: UITextField!
    @IBOutlet weak var cafenameTextfieldTH: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var typeTableView: UITableView!
    
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let lightgray = UIColor.init(red: 240/255, green: 240/255, blue: 241/255, alpha: 1)
    var areaOptions = [String]()
    var typeArray = [String]()
    var selectedArray = [String]()
    var unSelectedArray = [String]()
    var latitude1 = Double()
    var longitude1 = Double()
    var success1 = false
    var delegate: RegisterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true //เอาไว้ใช้ตอนที่ตรงแถบ nav bar ด้านบนเป็นสีดำเอง
        hideKeyboard()
        setupBackButtonNavBar()
        setupTextField()
        setNextButton()
        setKeyboardUnderTextField()
        typeTableView.delegate = self
        typeTableView.dataSource = self
        typeTableView.allowsMultipleSelection = true
        locationTextField.delegate = self
        setPickerView()
        
        areaOptions = ["ธนบุรี", "เยาวราช", "เจริญกรุง", "สีลม", "สามย่าน", "สยาม", "พระนคร", "ทองหล่อ", "อารีย์", "เกษตรนวมินทร์", "ลาดพร้าว", "บางนา", "รามอินทรา"]
        typeArray = ["คาเฟ่", "ร้านอาหาร", "co-working space", "บาร์", "ขนมหวาน", "ขนมไทย", "เบเกอรี่", "เครื่องดื่ม"]
        typeTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if success1 == true {
            delegate?.register(success: true)
            performSegueToReturnBack()
            success1 = false
        }
    }
    
    func setNextButton() {
        let nextButton = UIButton()
        nextButton.setTitleColor(red, for: .normal)
        nextButton.setTitle("ต่อไป", for: .normal)
        nextButton.addTarget(self, action: #selector(openSignupVC22), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: nextButton)
        navigationItem.rightBarButtonItem = menuBarItem
    }
    
    func setPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.backgroundColor = lightgray
        areaTextField.inputView = pickerView
    }
    
    func areaEng(area_th: String) -> String {
        switch area_th {
        case "ธนบุรี":
            return "Thonburi"
        case "เยาวราช":
            return "Yaowarat"
        case "เจริญกรุง":
            return "Charoen Krung"
        case "สีลม":
            return "Silom"
        case "สามย่าน":
            return "Samyan"
        case "สยาม":
            return "Siam"
        case "พระนคร":
            return "Phra Nakhon"
        case "ทองหล่อ":
            return "Thonglor"
        case "อารีย์":
            return "Ari"
        case "เกษตรนวมินทร์":
            return "Kaset Nawamin"
        case "ลาดพร้าว":
            return "Lat Phrao"
        case "บางนา":
            return "Bangna"
        case "รามอินทรา":
            return "Ram Inthra"
        default:
            return ""
        }
    }
    
    @objc func openSignupVC22() {
        let cafename_en = cafenameTextFieldEN.text ?? ""
        let cafename_th = cafenameTextfieldTH.text ?? ""
        let location = locationTextField.text ?? ""
        let area_th = areaTextField.text ?? ""
        let ll_location = GeoPoint(latitude: latitude1, longitude: longitude1)
        
        let type = selectedArray.joined(separator: ", ")
        
        if cafename_th != "" && cafename_en != "" && location != "" && area_th != "" && type != "" {
            let signupVC22 = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC22") as! SignupVC22
            let area_en = areaEng(area_th: area_th)
            let cafeData = RegisterCafe(cafename_en: cafename_en, cafename_th: cafename_th, location: location, ll_location: ll_location, type: type, area_en: area_en, area_th: area_th)
            signupVC22.registerCafe = cafeData
            signupVC22.delegate = self
            self.navigationController?.pushViewController(signupVC22, animated: true)
        }
    }
    
    func setupTextField() {
        cafenameTextFieldEN.setBottomBorder()
        cafenameTextfieldTH.setBottomBorder()
        locationTextField.setBottomBorder()
        areaTextField.setBottomBorder()
    }
    
    @objc func openMapVC() {
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
}

extension SignupVC2: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = typeTableView.dequeueReusableCell(withIdentifier: "TypeCafeCell", for: indexPath) as! TypeCafeCell
        cell.typeLabel.text = "\(typeArray[indexPath.row])"
        print(typeArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("เลือก")
        let cell = typeTableView.cellForRow(at: indexPath) as! TypeCafeCell
        cell.checkImage.image = UIImage(named: "check.png")
        selectedArray.append(typeArray[indexPath.row])
        print(selectedArray)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("ไม่เลือก")
        let cell = typeTableView.cellForRow(at: indexPath) as! TypeCafeCell
        cell.checkImage.image = UIImage(named: "uncheck.png")
        if let index = selectedArray.firstIndex(of: typeArray[indexPath.row]) {
            selectedArray.remove(at: index)
        }
    }
}

extension SignupVC2: UITextFieldDelegate, SendAddressDelegate {
    func sendAddress(address: String, latitude: Double, longitude: Double) {
        locationTextField.text = address
        latitude1 = latitude
        longitude1 = longitude
        print("\(latitude) \(longitude)")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        if textField == locationTextField {
            let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
            if locationTextField.text != "" {
                mapVC.locationTF = locationTextField.text!
                mapVC.laTF = latitude1
                mapVC.longTF = longitude1
            }
            mapVC.delegate = self
            self.navigationController?.pushViewController(mapVC, animated: true)
        }
        return false
    }

}

extension SignupVC2: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return areaOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        areaTextField.text = areaOptions[row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SignupVC2 {
    
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

