//
//  EnableQueueVC.swift
//  queueApp
//
//  Created by Bambam on 4/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class EnableQueueVC: UIViewController {
    
    @IBOutlet weak var enableButton: UIButton!
    var cafe_id = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        goback()
        enableButton.layer.cornerRadius = 15
        enableButton.addTarget(self, action: #selector(openTimeVC), for: .touchUpInside)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
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
    
    @objc func openTimeVC() {
        let timeVC = self.storyboard?.instantiateViewController(withIdentifier: "TimeVC") as! TimeVC
        timeVC.cafe_id = cafe_id
        timeVC.from = "queue"
        self.navigationController?.pushViewController(timeVC, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
