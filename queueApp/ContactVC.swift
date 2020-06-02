//
//  ContactVC.swift
//  queueApp
//
//  Created by Bambam on 2/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

extension ContactVC: SendAddressDelegate {
    func sendAddress(address: String, latitude: Double, longitude: Double) {
        addressTextField.text = address
        self.latitude = latitude
        self.longitude = longitude
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(region, animated: true)
    }
    
}

class ContactVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField1: UITextField!
    @IBOutlet weak var phoneTextField2: UITextField!
    @IBOutlet weak var phoneTextField3: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let locationManager = CLLocationManager()
    let db = Firestore.firestore()
    var cafe_id = String()
    var latitude = Double()
    var longitude = Double()
    var vSpinner: UIView?
    let lightgray = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    var areaOptions = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        hideKeyboard()
        setupBackButtonNavBar()
        setupTextField()
        setKeyboardUnderTextField()
        setMapView()
        setPickerView()
        setLocationManager()
        setPinUsingMKPointAnnotation()
        getData()
        saveButton.layer.cornerRadius = 15
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
//        mapView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setMapView() {
//        let pin = UIImageView()
//        pin.image = UIImage(named: "mappin")
//        pin.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        pin.center = mapView.center
//        mapView.addSubview(pin)
        
        let map = UIView()
        map.frame = mapView.frame
        mapView.addSubview(map)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMapVC))
        map.isUserInteractionEnabled = true
        map.addGestureRecognizer(tap)
    }
    
    func setupTextField() {
        phoneTextField1.setBackground()
        phoneTextField2.setBackground()
        phoneTextField3.setBackground()
        addressTextField.setBackground()
        areaTextField.setBackground()
        
        
        phoneTextField1.delegate = self
        phoneTextField2.delegate = self
        phoneTextField3.delegate = self
    }
    
    func setPickerView() {
        let pickerView1 = UIPickerView()
        pickerView1.delegate = self
        pickerView1.backgroundColor = lightgray
        pickerView1.tag = 1
        areaTextField.inputView = pickerView1
        areaOptions = ["ธนบุรี", "เยาวราช", "เจริญกรุง", "สีลม", "สามย่าน", "สยาม", "พระนคร", "ทองหล่อ", "อารีย์", "เกษตรนวมินทร์", "ลาดพร้าว", "บางนา", "รามอินทรา"]
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
    
    @objc func openMapVC() {
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        print(latitude)
        print(longitude)
        mapVC.laTF = latitude
        mapVC.longTF = longitude
        mapVC.locationTF = addressTextField.text ?? ""
        mapVC.delegate = self
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    func getData() {
        db.collection("cafe").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let telArray = document.get("cafe_tel") as! [String]
                if telArray.count == 1 {
                    self.phoneTextField1.text = telArray[0]
                }
                else if telArray.count == 2 {
                    self.phoneTextField1.text = telArray[0]
                    self.phoneTextField2.text = telArray[1]
                }
                else {
                    self.phoneTextField1.text = telArray[0]
                    self.phoneTextField2.text = telArray[1]
                    self.phoneTextField3.text = telArray[2]
                }
                
                let location = document.get("location") as! String
                let ll_location = document.get("ll_location") as! GeoPoint
                let ll = CLLocationCoordinate2D(latitude: ll_location.latitude, longitude: ll_location.longitude)
                let region = MKCoordinateRegion(center: ll, latitudinalMeters: 200, longitudinalMeters: 200)
                let area_th = document.get("area_th") as! String
                self.areaTextField.text = area_th
                self.mapView.setRegion(region, animated: true)
                self.addressTextField.text = location
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getLatitudeAndLongitude(cafe_id: String, dispatch:DispatchGroup, completed: @escaping (Double,Double) -> Void) {
        let data = db.collection("cafe").document(cafe_id)
        dispatch.enter()
        data.getDocument { (document, err) in
            if let document = document, document.exists {
                let ll_location = document.get("ll_location") as! GeoPoint
                self.latitude = ll_location.latitude
                self.longitude = ll_location.longitude
            }
            else {
                print("Document does not exist")
            }
            dispatch.leave()
        }
        dispatch.notify(queue: .main, execute: {
            completed(self.latitude,self.longitude)
        })
    }
        
    func setPinUsingMKPointAnnotation(){
        let dispatch = DispatchGroup()
        self.getLatitudeAndLongitude(cafe_id: cafe_id, dispatch: dispatch){ (latitude,longitude) in
            dispatch.notify(queue: .main, execute: {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
                
                self.mapView.addAnnotation(annotation)
                            
                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
                self.mapView.setRegion(region, animated: true)
            })
        }
    }
    
    @objc func save() {
        loading(self.view)
        let location = addressTextField.text ?? ""
        let phone1 = phoneTextField1.text ?? ""
        let phone2 = phoneTextField2.text ?? ""
        let phone3 = phoneTextField3.text ?? ""
        let area_th = areaTextField.text ?? ""
        var phoneArray = [String]()
        if phone1 != "" {
            phoneArray.append(phone1)
        }
        if phone2 != "" {
            phoneArray.append(phone2)
        }
        if phone3 != "" {
            phoneArray.append(phone3)
        }
        let area_en = areaEng(area_th: area_th)
        
        let data = [
            "location" : location,
            "ll_location" : GeoPoint(latitude: latitude, longitude: longitude),
            "cafe_tel" : phoneArray,
            "area_th" : area_th,
            "area_en" : area_en
            ] as [String : Any]
        
        let cafeRef = db.collection("cafe").document(cafe_id)
        cafeRef.updateData(data) { err in
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

extension ContactVC {
    
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

extension ContactVC: UITextFieldDelegate {
    
    func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX-XXX-XXXX"

        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTextField1 {
            guard let text = phoneTextField1.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            phoneTextField1.text = formattedNumber(number: newString)
        }
        else if textField == phoneTextField2 {
            guard let text = phoneTextField2.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            phoneTextField2.text = formattedNumber(number: newString)
        }
        else if textField == phoneTextField3 {
            guard let text = phoneTextField3.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            phoneTextField3.text = formattedNumber(number: newString)
        }
        return false
    }
}

extension ContactVC {
    
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

extension ContactVC: UIPickerViewDelegate, UIPickerViewDataSource {
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
        if pickerView.tag == 1 {
            areaTextField.text = areaOptions[row]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
