//
//  ViewController.swift
//  queueApp
//
//  Created by Bambam on 20/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

extension ViewController : RegisterDelegate {
    func register(success: Bool) {
        success1 = success
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var appLogoImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    var success1 = false
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        loginButton.addTarget(self, action: #selector(openloginVC), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(openSignupVC), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if success1 == true {
            try! Auth.auth().signOut()
            self.dismiss(animated: false, completion: nil)
            success1 = false
        }
        else {
            if let email = Auth.auth().currentUser {
                self.performSegue(withIdentifier: "toHomeVC", sender: self)
            }
        }
    }
    
    func setupButton() {
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = red.cgColor
        signupButton.layer.cornerRadius = 5
        signupButton.backgroundColor = .white
        
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = red
        
    }
    
    @objc func openSignupVC() {
        let findCafeVC = self.storyboard?.instantiateViewController(withIdentifier: "FindCafeVC") as! FindCafeVC
        findCafeVC.delegate = self
        self.navigationController?.pushViewController(findCafeVC, animated: true)
    }
    
    @objc func openloginVC() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}

