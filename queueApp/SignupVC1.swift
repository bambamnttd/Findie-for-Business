//
//  SignupVC1.swift
//  queueApp
//
//  Created by Bambam on 27/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

class SignupVC1: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cafeImage: UIImageView!
    @IBOutlet weak var cafenameLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    let db = Firestore.firestore()
    let gray = UIColor.init(red: 196/255, green: 196/255, blue: 198/255, alpha: 1)
    let lightgray = UIColor.init(red: 240/255, green: 240/255, blue: 241/255, alpha: 1)
    var cafe_id = String()
    var cafe_imageURL = String()
    var delegate : RegisterDelegate?
    var vSpinner : UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupBackButtonNavBar()
        setupCardView()
        setKeyboardUnderTextField()
        
        nameTextField.setBottomBorder()
        emailTextField.setBottomBorder()
        phoneTextField.setBottomBorder()
        phoneTextField.delegate = self
        
        signupButton.layer.cornerRadius = 5
        
        if cafe_imageURL != "" {
            cafeImage.setImage(cafe_imageURL)
        }
        else {
            cafeImage.image = UIImage(named: "background.png")
        }
        getCafeData()
        signupButton.addTarget(self, action: #selector(signup), for: .touchUpInside)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    func setupCardView() {
        cardView.layer.cornerRadius = 5
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = gray.cgColor
    }
    
    func getCafeData() {
        let data = db.collection("cafe").document(cafe_id)
        data.getDocument { (document, err) in
            if let document = document, document.exists {
                let cafename_en = document.get("cafename_en") as! String
                let cafename_th = document.get("cafename_th") as! String
                let location = document.get("location") as! String
                let tel = document.get("cafe_tel") as! [String]
                if tel.count > 1 {
                    self.telLabel.setImageInLabel(text: tel.joined(separator: ", "), image: UIImage(named: "tel.png")!, x: 0, y: -1, width: 12, height: 12)
                }
                else {
                    self.telLabel.setImageInLabel(text: tel[0], image: UIImage(named: "tel.png")!, x: 0, y: -1, width: 12, height: 12)
                }
                self.cafenameLabel.text = "\(cafename_en) \(cafename_th)"
                self.locationLabel.setImageInLabel(text: location, image: UIImage(named: "locationpin.png")!, x: 0, y: -1, width: 12, height: 12)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func addDataToCafeOwner(password: String) {
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let phone = phoneTextField.text else { return }
        let uid = Auth.auth().currentUser?.uid
        
        let ownerData = [
            "owner_name": name,
            "email": email,
            "phone_number": [phone],
            "password": password,
            "owner_id": uid!,
            "cafe_id": cafe_id,
            "status": "processing",
            "createdate": FieldValue.serverTimestamp()
        ] as [String : Any]
        loading(self.view)
        db.collection("cafe_owner").document(uid!).setData(ownerData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written! \(uid!)")
                self.removeLoading()
            }
        }
    }
    
    @objc func signup() {
        guard let email = emailTextField.text else { return }
        let password = UUID().uuidString

        Auth.auth().createUser(withEmail: email, password: password) { name, error in
            if error == nil && name != nil {
                print("ลงทะเบียนเรียบร้อยแล้ว!")
                self.addDataToCafeOwner(password: password)
                let changRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changRequest?.displayName = email
                changRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        let alert = UIAlertController(title: "คุณได้ลงทะเบียนเรียบร้อยแล้ว", message: "ทางทีมงานจะติดต่อคุณกลับไปภายใน 2 วัน", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                            self.delegate?.register(success: true)
                            self.performSegueToReturnBack()
                        }))
                        self.present(alert, animated: true)
                    }
                }
                        
            } else {
                print("ลงทะเบียนไม่สำเร็จ: \(error! .localizedDescription)")
                let alert = UIAlertController(title: "ลงทะเบียนไม่สำเร็จ", message: "อีเมลนี้ถูกใช้ไปแล้ว", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ตกลง", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
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

extension SignupVC1 {
    
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

extension SignupVC1 {
    
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

