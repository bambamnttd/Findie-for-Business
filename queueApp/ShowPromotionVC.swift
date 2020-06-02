//
//  ShowPromotionVC.swift
//  queueApp
//
//  Created by Bambam on 4/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

struct PromotionData {
    var promotion_id: String
    var promotion_topic: String
    var enddate: String
    var startdate: String
    var promotion_imageURL: String
    var createdate: Date
}
class ShowPromotionVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var promotionArray = [PromotionData]()
    var cafe_id = String()
    let db = Firestore.firestore()
    let storageRef = Storage.storage()
    var user = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        goback()
        table.dataSource = self
        table.delegate = self
        getPromotionData()
        addButton.addTarget(self, action: #selector(openPromotionVC), for: .touchUpInside)
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
        if user == "new" {
            self.dismiss(animated: true, completion: nil)
        } else {
            performSegueToReturnBack()
        }
    }
    
    @objc func openPromotionVC() {
        let promotionVC = self.storyboard?.instantiateViewController(withIdentifier: "PromotionVC") as! PromotionVC
        promotionVC.cafe_id = cafe_id
        promotionVC.user = "old"
        self.navigationController?.pushViewController(promotionVC, animated: true)
    }
    
    func getPromotionData() {
        db.collection("promotion").whereField("cafe_id", isEqualTo: cafe_id).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.promotionArray.removeAll()
            for doc in documents {
                let topic = doc.get("promotion_topic") as! String
                let image = doc.get("promotion_imageURL") as! String
                let startdate = doc.get("startdate") as! Timestamp
                let enddate = doc.get("enddate") as! Timestamp
                let createdate = doc.get("createdate") as! Timestamp
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yy"
                self.promotionArray.append(PromotionData(promotion_id: doc.documentID, promotion_topic: topic, enddate: dateFormatter.string(from: enddate.dateValue()), startdate: dateFormatter.string(from: startdate.dateValue()), promotion_imageURL: image, createdate: createdate.dateValue()))
                self.promotionArray = self.promotionArray.sorted { $0.createdate > $1.createdate }
            }
            self.table.reloadData()
        }
    }
    
    func deletePromotion(promotion_id: String, imageURL: String) {
        db.collection("promotion").document(promotion_id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                let desertRef = self.storageRef.reference(forURL: imageURL)
                desertRef.delete { error in
                  if let error = error {
                    print("error")
                  } else {
                    print("ลบรูปเรียบร้อย")
                  }
                }
            }
        }
    }
}

extension ShowPromotionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promotionArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "ShowPromotionCell", for: indexPath) as? ShowPromotionCell else {
            return UITableViewCell()
        }
        cell.topicLabel.text = promotionArray[indexPath.row].promotion_topic
        cell.dateLabel.text = "ระยะเวลา : \(promotionArray[indexPath.row].startdate) - \(promotionArray[indexPath.row].enddate)"
        if promotionArray[indexPath.row].promotion_imageURL == "" {
            cell.proImage.image = UIImage(named: "background.png")
        } else {
            cell.proImage.setImage(promotionArray[indexPath.row].promotion_imageURL)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePromotion(promotion_id: promotionArray[indexPath.row].promotion_id, imageURL: promotionArray[indexPath.row].promotion_imageURL)
            promotionArray.remove(at: indexPath.row)
            table.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
