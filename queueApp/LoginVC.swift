//
//  LogInVC.swift
//  queueApp
//
//  Created by Bambam on 25/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var appLogoImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let db = Firestore.firestore()
    var vSpinner: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupButton()
        setupTextField()
        setupBackButtonNavBar()
        setKeyboardUnderTextField()
        
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        let text = "สวัสดีค่ะทุกคน"

        if let language = NSLinguisticTagger.dominantLanguage(for: text) {
            print(language)
        } else {
            print("Unknown language")
        }
    }
    
    func setupButton() {
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = red
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    
    func setupTextField() {
        emailTextField.setBottomBorder()
        emailTextField.addDoneButtonOnKeyboard()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.setBottomBorder()
        passwordTextField.addDoneButtonOnKeyboard()
        passwordTextField.placeholder = "••••••••••••"
    }
    
    @objc func login() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        db.collection("cafe_owner").whereField("email", isEqualTo: emailTextField.text!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print(email)
                    self.loading(self.view)
                    let status = document.get("status") as! String
                    if status == "success" {
                        Auth.auth().signIn(withEmail: email, password: password) { email, error in
                            if error == nil && email != nil {
                                print("เข้าสู่ระบบสำเร็จ")
                                self.removeLoading()
                                self.performSegueToReturnBack()
                            } else {
                                self.removeLoading()
                                print("เข้าสู่ระบบไม่สำเร็จ: \(error! .localizedDescription)")
                                let alert = UIAlertController(title: "เข้าสู่ระบบไม่สำเร็จ", message: "อีเมลหรือรหัสผ่านไม่ถูกต้อง", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "ตกลง", style: .cancel, handler: nil))
                                self.present(alert, animated: true)
                            }
                        }
                    }
                    else {
                        self.removeLoading()
                        let alert = UIAlertController(title: "อีเมลนี้อยู่ในระหว่างตรวจสอบข้อมูล", message: "ขออภัยในความไม่สะดวก", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ตกลง", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    
}

extension LoginVC {
    
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

extension LoginVC {
    
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

