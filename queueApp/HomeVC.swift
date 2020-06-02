//
//  HomeVC.swift
//  queueApp
//
//  Created by Bambam on 29/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var cafenameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var queueView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var promotionView: UIView!
    @IBOutlet weak var rewardView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var reviewView: UIView!
    
    @IBOutlet weak var contactUsView: UIView!
    
    @IBOutlet weak var badgeQueueLabel: UILabel!
    
    let db = Firestore.firestore()
    var cafeidLabel = UILabel()
    var vSpinner: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        setupView()
        setupSettingOnNavBar()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        getCafeData()
        badgeQueueLabel.layer.cornerRadius = badgeQueueLabel.bounds.height / 2
        badgeQueueLabel.layer.masksToBounds = true
        badgeQueueLabel.isHidden = true
    }
    
    func setupSettingOnNavBar() {
        let settingButton = UIButton()
        settingButton.setImage(UIImage(named: "logout.png"), for: .normal)
        settingButton.tintColor = .white
        settingButton.addTarget(self, action: #selector(signout), for: .touchUpInside)
        settingButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let menuBarItem = UIBarButtonItem(customView: settingButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 25)
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 25)
        currWidth?.isActive = true
        currHeight?.isActive = true
    
        navigationItem.rightBarButtonItem = menuBarItem
    }
    
    func setupView() {
        queueView.setShadow()
        infoView.setShadow()
        promotionView.setShadow()
        rewardView.setShadow()
        reviewView.setShadow()
        imageView.setShadow()
        
        let queuetap = UITapGestureRecognizer(target: self, action: #selector(openQueueListVC))
        queueView.isUserInteractionEnabled = true
        queueView.addGestureRecognizer(queuetap)
        
        let infotap = UITapGestureRecognizer(target: self, action: #selector(openInfoListVC))
        infoView.isUserInteractionEnabled = true
        infoView.addGestureRecognizer(infotap)
        
        let promotiontap = UITapGestureRecognizer(target: self, action: #selector(openPromotionVC))
        promotionView.isUserInteractionEnabled = true
        promotionView.addGestureRecognizer(promotiontap)
        
        let rewardtap = UITapGestureRecognizer(target: self, action: #selector(openRewardVC))
        rewardView.isUserInteractionEnabled = true
        rewardView.addGestureRecognizer(rewardtap)
        
        let imagetap = UITapGestureRecognizer(target: self, action: #selector(openImageVC))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imagetap)
        
        let reviewtap = UITapGestureRecognizer(target: self, action: #selector(openReviewVC))
        reviewView.isUserInteractionEnabled = true
        reviewView.addGestureRecognizer(reviewtap)
        
        let contactUsTap = UITapGestureRecognizer(target: self, action: #selector(contactUs))
        contactUsView.isUserInteractionEnabled = true
        contactUsView.addGestureRecognizer(contactUsTap)
    }
    
    func setImage() {
        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.4
        darkView.frame = coverImage.bounds
        coverImage.addSubview(darkView)
        
//        logoImage.layer.borderColor = UIColor.white.cgColor
//        logoImage.layer.borderWidth = 2
        logoImage.layer.cornerRadius = logoImage.bounds.height / 2
    }
    
    func getCafeData() {
        let owner_id = Auth.auth().currentUser?.uid
        print(owner_id!)
        loading(self.view)
        db.collection("cafe_owner").document(owner_id!).getDocument { (document, error) in
            if let document = document, document.exists {
                let cafe_id = document.get("cafe_id") as! String
                self.cafeidLabel.text = cafe_id
                self.getReviewTotal(cafe_id: cafe_id)
                self.getFavoriteTotal(cafe_id: cafe_id)
                self.getQueueTotal(cafe_id : cafe_id)
                self.db.collection("cafe").document(cafe_id).addSnapshotListener { documentSnapshot, er in
                    guard let doc = documentSnapshot else {
                        print("Error fetching document: \(er!)")
                        return
                    }
                    let cafename_en = doc.get("cafename_en") as! String
                    let type = doc.get("type") as! String
                    let rating = doc.get("rating") as! Float
                    self.cafenameLabel.text = cafename_en
                    self.typeLabel.text = type
                    self.ratingLabel.text = "\(rating)"
                    if rating == 0 {
                        self.ratingLabel.text = "0"
                    }
                    self.db.collection("cafe_image").document(cafe_id).addSnapshotListener { documentSnapshot, err in
                        guard let docc = documentSnapshot else {
                            print("Error fetching document: \(err!)")
                            return
                        }
                        let cover = docc.get("cafe_cover") as! String
                        let logo = docc.get("cafe_logo") as! String
                        if cover == "" {
                            self.coverImage.image = UIImage(named: "background.png")
                        } else {
                            self.coverImage.setImage(cover)
                        }
                        if logo == "" {
                            self.logoImage.image = UIImage(named: "background.png")
                        } else {
                            self.logoImage.setImage(logo)
                        }
                        self.removeLoading()
                    }
                }
            } else {
                self.removeLoading()
                print("Document does not exist")
            }
        }
    }
    
    func getReviewTotal(cafe_id: String) {
        db.collection("review").whereField("cafe_id", isEqualTo: cafe_id).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.reviewLabel.text = "\(documents.count)"
        }
    }
    
    func getFavoriteTotal(cafe_id : String) {
        db.collection("favorite").whereField("cafe_id", isEqualTo: cafe_id).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.favoriteLabel.text = "\(documents.count)"
        }
    }
    
    func getQueueTotal(cafe_id : String) {
        db.collection("queue").whereField("cafe_id", isEqualTo: cafe_id).whereField("status", isEqualTo: "booked").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            if documents.count > 0 {
                self.badgeQueueLabel.isHidden = false
                self.badgeQueueLabel.text = "\(documents.count)"
                print("มี")
            } else {
                self.badgeQueueLabel.isHidden = true
                print("ไม่มี")
            }
        }
    }
    
    @objc func openQueueListVC() {
        let cafe_id = cafeidLabel.text!
        db.collection("cafe").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let booking = document.get("booking") as! Bool
                if booking == false {
                    let enableQueueVC = self.storyboard?.instantiateViewController(withIdentifier: "EnableQueueVC") as! EnableQueueVC
                    let navController = UINavigationController(rootViewController: enableQueueVC)
                    enableQueueVC.modalPresentationStyle = .fullScreen
                    navController.modalPresentationStyle = .fullScreen
                    enableQueueVC.cafe_id = cafe_id
                    self.present(navController, animated:true, completion: nil)
                }
                else {
                    let queueListVC = self.storyboard?.instantiateViewController(withIdentifier: "QueueListVC") as! QueueListVC
                    print("มีการจองคิวแล้ว")
                    queueListVC.cafe_id = cafe_id
                    self.navigationController?.pushViewController(queueListVC, animated: true)
                }
            }
        }
    }
    
    @objc func openInfoListVC() {
        let infoListVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoListVC") as! InfoListVC
        infoListVC.cafe_id = cafeidLabel.text!
        self.navigationController?.pushViewController(infoListVC, animated: true)
    }
    
    @objc func openPromotionVC() {
        let cafe_id = cafeidLabel.text!
            db.collection("cafe").document(cafe_id).getDocument { (document, error) in
                if let document = document, document.exists {
                    let promotion = document.get("promotion") as! Bool
                    if promotion == false {
                        let enablePromotionVC = self.storyboard?.instantiateViewController(withIdentifier: "EnablePromotionVC") as! EnablePromotionVC
                        let navController = UINavigationController(rootViewController: enablePromotionVC)
                        enablePromotionVC.modalPresentationStyle = .fullScreen
                        navController.modalPresentationStyle = .fullScreen
                        enablePromotionVC.cafe_id = cafe_id
                        self.present(navController, animated:true, completion: nil)
                    }
                    else {
                        let showPromotionVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowPromotionVC") as! ShowPromotionVC
                        showPromotionVC.cafe_id = cafe_id
                        self.navigationController?.pushViewController(showPromotionVC, animated: true)
                        print("มีโปรโมชั่นแล้ว")
                    }
                }
            }
    }
    
    @objc func openRewardVC() {
        let cafe_id = cafeidLabel.text!
        db.collection("cafe").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let membercard = document.get("membercard") as! Bool
                if membercard == false {
                    let rewardVC = self.storyboard?.instantiateViewController(withIdentifier: "RewardVC") as! RewardVC
                    let navController = UINavigationController(rootViewController: rewardVC)
                    rewardVC.modalPresentationStyle = .fullScreen
                    navController.modalPresentationStyle = .fullScreen
                    rewardVC.cafe_id = cafe_id
                    self.present(navController, animated:true, completion: nil)
                }
                else {
                    print(cafe_id)
                    let showRewardVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowRewardVC") as! ShowRewardVC
                    showRewardVC.cafe_id = cafe_id
                    self.navigationController?.pushViewController(showRewardVC, animated: true)
                    print("มีการ์ดแล้ว")
                }
            }
        }
    }
    
    @objc func openImageVC() {
        let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as! ImageVC
        imageVC.cafe_id = cafeidLabel.text!
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
    
    @objc func openReviewVC() {
        let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewVC") as! ReviewVC
        reviewVC.cafe_id = cafeidLabel.text!
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    @objc func contactUs() {
        let optionMenu = UIAlertController(title: "ติดต่อฝ่ายบริการลูกค้า Findie for Business", message: nil, preferredStyle: .actionSheet)
        let phone1 = "095-629-2651"
        let phone2 = "06-5597-9887"
        let phoneCallAction1 = UIAlertAction(title: phone1, style: .default) { (action) in
            if let url = URL(string: "tel://\(phone1)"),
            UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let phoneCallAction2 = UIAlertAction(title: phone2, style: .default) { (action) in
            if let url = URL(string: "tel://\(phone2)"),
            UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        optionMenu.addAction(phoneCallAction1)
        optionMenu.addAction(phoneCallAction2)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
            
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func signout() {
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }

}

extension HomeVC {
    
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

