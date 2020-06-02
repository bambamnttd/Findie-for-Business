//
//  RewardVC.swift
//  queueApp
//
//  Created by Bambam on 30/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class RewardVC: UIViewController {
    
    @IBOutlet weak var enableButton: UIButton!
    
    var cafe_id = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        goback()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        enableButton.addTarget(self, action: #selector(openEditRewardVC), for: .touchUpInside)
        enableButton.layer.cornerRadius = 15
    }
    
    func goback() {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back_red.png"), for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 28)
            
        let menuBarItem = UIBarButtonItem(customView: backButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 40)
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        currHeight?.isActive = true
        
        navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openEditRewardVC() {
        let editRewardVC2 = self.storyboard?.instantiateViewController(withIdentifier: "EditRewardVC2") as! EditRewardVC2
        editRewardVC2.user = "new"
        editRewardVC2.cafe_id = cafe_id
        self.navigationController?.pushViewController(editRewardVC2, animated: true)
    }
}
