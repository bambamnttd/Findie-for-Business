//
//  QueueListCell.swift
//  queueApp
//
//  Created by Bambam on 30/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

class QueueListCell: UITableViewCell {
    
//    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var queueNumberLabel: UILabel!
//    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var comeButton: UIButton!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var categoryLabel1: UILabel!
    @IBOutlet weak var categoryLabel2: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    let db = Firestore.firestore()
    var data : Queue!

    override func awakeFromNib() {
        super.awakeFromNib()
        //setBackgroundView()
//        userImage.layer.cornerRadius = 5
        categoryView.layer.cornerRadius = 15
        bgView.layer.cornerRadius = 15
        bgView.layer.borderColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
        bgView.layer.borderWidth = 1
        
        comeButton.isHidden = true
        passButton.isHidden = true
        callButton.layer.cornerRadius = callButton.bounds.height/2
        comeButton.layer.cornerRadius = comeButton.bounds.height/2
        passButton.layer.cornerRadius = passButton.bounds.height/2
        
        callButton.addTarget(self, action: #selector(call), for: .touchUpInside)
        comeButton.addTarget(self, action: #selector(come), for: .touchUpInside)
        passButton.addTarget(self, action: #selector(pass), for: .touchUpInside)
    }
    
    func setBackgroundView() {
        bgView.layer.cornerRadius = 15
        bgView.layer.shadowColor = UIColor.gray.cgColor
        bgView.layer.shadowOffset = CGSize(width: 2, height: 2)
        bgView.layer.shadowRadius = 3.5
        bgView.layer.shadowOpacity = 0.4
        bgView.layer.shadowPath = UIBezierPath(rect: bgView.bounds).cgPath
        bgView.layer.shouldRasterize = true
        bgView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc func call() {
        let queue_id = data.queue_id
        let queueRef = db.collection("queue").document(queue_id)
        queueRef.updateData([
            "status": "called"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Queue's status updated to be 'called'")
                self.callButton.isHidden = true
                self.comeButton.isHidden = false
                self.passButton.isHidden = false
            }
        }
    }
    
    @objc func come() {
        self.comeButton.isHidden = true
        self.passButton.isHidden = true
        let queue_id = data.queue_id
        let queueRef = db.collection("queue").document(queue_id)
        queueRef.updateData([
            "status": "done"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Queue's status updated to be 'done'")
            }
        }
    }
    
    @objc func pass() {
        self.comeButton.isHidden = true
        self.passButton.isHidden = true
        let queue_id = data.queue_id
        let queueRef = db.collection("queue").document(queue_id)
        queueRef.updateData([
            "status": "passed"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Queue's status updated to be 'passed'")
//                queueRef.delete() { error in
//                    if let error = error {
//                        print("Error removing document: \(error)")
//                    } else {
//                        print("Document successfully removed!")
//                    }
//                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
