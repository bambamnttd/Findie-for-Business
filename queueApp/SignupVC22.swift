//
//  SignupVC22.swift
//  queueApp
//
//  Created by Bambam on 29/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

struct RegisterOwner {
    var owner_name: String
    var email: String
    var phone: [String]
    var password: String
}

protocol RegisterDelegate: class {
    func register(success: Bool)
}
class SignupVC22: UIViewController {

    ///owner info
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var passwordWarning: UILabel!
    @IBOutlet weak var confirmWarning: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupButton: UIButton!
    
    let db = Firestore.firestore()
    var registerCafe: RegisterCafe!
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let gray = UIColor.init(red: 196/255, green: 196/255, blue: 198/255, alpha: 1)
    var delegate : RegisterDelegate?
    var vSpinner: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupTextField()
        setKeyboardUnderTextField()
        setupBackButtonNavBar()
        passwordWarning.text = ""
        confirmWarning.text = ""
        phoneTextField.delegate = self
        
        passwordTextField.addTarget(self, action: #selector(checkPassword(textfield:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(checkComfirmPassword(textfield:)), for: .editingChanged)
        signupButton.addTarget(self, action: #selector(signup), for: .touchUpInside)
        signupButton.layer.cornerRadius = 5
        print(registerCafe!)
    }
    
    func setupTextField() {
        nameTextField.setBottomBorder()
        emailTextField.setBottomBorder()
        phoneTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        confirmPasswordTextField.setBottomBorder()
        
//        confirmPasswordTextField.delegate = self
    }
    
    func checkTextFieldNotEmpty(_ textField: UITextField) {
        if textField.text! == "" {
            textField.layer.shadowColor = red.cgColor
        }
        else {
            textField.layer.shadowColor = gray.cgColor
        }
    }
    
    @objc func checkComfirmPassword(textfield: UITextField) {
        if passwordTextField.text! != textfield.text! {
            confirmWarning.text = "รหัสผ่านไม่ตรงกัน"
            confirmWarning.textColor = .red
        }
        else {
            confirmWarning.text = ""
        }
    }
    
    @objc func checkPassword(textfield: UITextField) {
        if (passwordTextField.text?.count ?? 0 < 8) {
            passwordWarning.text = "รหัสผ่านอย่างน้อย 8 ตัว"
            passwordWarning.textColor = .red
        }
        else{
            passwordWarning.text = ""
        }
    }
    
    @objc func signup() {
        checkTextFieldNotEmpty(nameTextField)
        checkTextFieldNotEmpty(emailTextField)
        checkTextFieldNotEmpty(phoneTextField)
        checkTextFieldNotEmpty(passwordTextField)
        checkTextFieldNotEmpty(confirmPasswordTextField)
        
        let owner_name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""

        if owner_name != "" && email != "" && phone != "" && password != "" && confirmPassword != "" {
            Auth.auth().createUser(withEmail: email, password: password) { name, error in
                if error == nil && name != nil {
                    self.loading(self.view)
                    print("ลงทะเบียนเรียบร้อยแล้ว!")
                    let changRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changRequest?.displayName = email
                    changRequest?.commitChanges { error in
                        if error == nil {
                            print("User display name changed!")
                            let owner_id = Auth.auth().currentUser?.uid
                            print(owner_id)
                            print([phone])
                            print(email)
                            print(password)
                            self.addToDatabase(owner_id: owner_id!, owner_name: owner_name, email: email, phone: [phone], password: password)
                        }
                    }
                } else {
                    print("ลงทะเบียนไม่สำเร็จ: \(error! .localizedDescription)")
                    self.removeLoading()
                    let alert = UIAlertController(title: "ลงทะเบียนไม่สำเร็จ", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ตกลง", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func addToDatabase(owner_id: String, owner_name: String, email: String, phone: [String], password: String) {
        let cafeData = [
            "cafe_id": "",
            "owner_id": owner_id,
            "cafename_en": registerCafe.cafename_en,
            "cafename_th": registerCafe.cafename_th,
            "type": registerCafe.type,
            "area_en": registerCafe.area_en,
            "area_th": registerCafe.area_th,
            "location": registerCafe.location,
            "ll_location": registerCafe.ll_location,
            "cafe_tel": phone,
            "rating": 0,
            "price": "",
            "opening_time": [
                "Monday": "",
                "Tuesday": "",
                "Wednesday": "",
                "Thursday": "",
                "Friday": "",
                "Saturday": "",
                "Sunday": ""
            ],
            "membercard": false,
            "booking": false,
            "promotion": false,
            "wifi": false,
            "carpark": false,
            "delivery": false,
            "onlinePayment": false,
            "creditcard": false,
            "table_amount": "",
            "createdate": FieldValue.serverTimestamp()
        ] as [String : Any]
            
        var ref: DocumentReference? = nil
        ref = db.collection("cafe").addDocument(data: cafeData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID) to Cafe")
                let cafeRef = self.db.collection("cafe").document(ref!.documentID)
                cafeRef.updateData([
                    "cafe_id" : "\(ref!.documentID)"
                ]) { er in
                    if let er = er {
                        print("Error updating document: \(er)")
                    } else {
                        print("Document successfully updated to Cafe")
                        
                        let ownerData = [
                            "owner_name": owner_name,
                            "email": email,
                            "phone_number": phone,
                            "password": password,
                            "owner_id": owner_id,
                            "cafe_id": ref!.documentID,
                            "status": "success",
                            "createdate": FieldValue.serverTimestamp()
                        ] as [String : Any]
                        
                        self.db.collection("cafe_owner").document(owner_id).setData(ownerData) { error in
                            if let error = error {
                                print("Error writing document: \(error)")
                            } else {
                                print("Document successfully written! \(owner_id) to Cafe_ownner")
                                
                                let imageData = [
                                    "cafe_id": ref!.documentID,
                                    "cafe_image": [],
                                    "cafe_cover": "",
                                    "cafe_logo": "",
                                    "cafe_menu": [],
                                    "cafe_color": ["red": 0, "grren": 0, "blue": 0]
                                    ] as [String : Any]
                                self.db.collection("cafe_image").document(ref!.documentID).setData(imageData) { errr in
                                    if let errr = errr {
                                        print("Error writing document: \(errr)")
                                    } else {
                                        print("Document successfully written! \(ref!.documentID) to cafe_image")
                                        self.removeLoading()
                                        let alert = UIAlertController(title: "คุณได้ลงทะเบียนเรียบร้อยแล้ว", message: nil, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                            self.delegate?.register(success: true)
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
    }
}

extension SignupVC22 {
    ///set up keyboard under text field
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

extension SignupVC22: UITextFieldDelegate {
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
        guard let text = phoneTextField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        phoneTextField.text = formattedNumber(number: newString)
        return false
    }
}

extension SignupVC22 {
    
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

