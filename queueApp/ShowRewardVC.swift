//
//  ShowRewardVC.swift
//  queueApp
//
//  Created by Bambam on 4/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ShowRewardVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var expdateLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var bulletTextView: UITextView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var editConditionButton: UIButton!
    @IBOutlet weak var addRewardButton: UIButton!
    
    var cafe_id = String()
    let db = Firestore.firestore()
    var rewardArray = [RewardData]()
    var strings = [String]()
    var user = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        if user == "new" {
            setGoback()
        } else {
            setupBackButtonNavBar()
        }
        showData()
        getData()
        showImageCard()
        setImageCard()
        addRewardButton.addTarget(self, action: #selector(openEditRewardVC2), for: .touchUpInside)
        editConditionButton.addTarget(self, action: #selector(openConditionVC), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = table.contentSize.height
        table.frame = CGRect(x: table.frame.origin.x, y: table.frame.origin.y, width: table.frame.size.width, height: table.contentSize.height)
//        tableHeight.constant = CGFloat(self.rewardArray.count * 80)
        table.reloadData()

//        if .frame.origin.y >= 620 {
//            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 950)
//        }
        //self.view.layoutIfNeeded()
    }
    
//    override func viewWillLayoutSubviews(){
//        super.viewWillLayoutSubviews()
//        tableHeight.constant = CGFloat(self.rewardArray.count * 80)
//        table.reloadData()
//        print(tableHeight.constant)
//    }
    
    @objc func openEditRewardVC2() {
        let editRewardVC2 = self.storyboard?.instantiateViewController(withIdentifier: "EditRewardVC2") as! EditRewardVC2
        editRewardVC2.cafe_id = cafe_id
        editRewardVC2.user = "adding"
        self.navigationController?.pushViewController(editRewardVC2, animated: true)
    }
    
    func setGoback() {
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
    
    @objc func openConditionVC() {
        let conditionVC = self.storyboard?.instantiateViewController(withIdentifier: "ConditionVC") as! ConditionVC
        conditionVC.cafe_id = cafe_id
        conditionVC.from = "ShowRewardVC"
        self.navigationController?.pushViewController(conditionVC, animated: true)
    }
    
    func setImageCard() {
        logoImage.layer.cornerRadius = logoImage.bounds.height / 2
        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.4
        darkView.frame = coverImage.bounds
        coverImage.addSubview(darkView)
    }
    
    func showData() {
        db.collection("cafe").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let name = document.get("cafename_en") as! String
                let type = document.get("type") as! String
                self.nameLabel.text = name
                self.typeLabel.text = type
            }
            else {
                print("ไม่มีข้อมูล")
            }
        }
    }
    
    func showImageCard() {
        db.collection("cafe_image").document(cafe_id).getDocument { (document, error) in
            if let document = document, document.exists {
                let logo = document.get("cafe_logo") as! String
                let cover = document.get("cafe_cover") as! String
                let color = document.get("cafe_color") as! [String: Float]
                
                if logo != "" {
                    self.logoImage.setImage(logo)
                } else {
                    self.logoImage.image = UIImage(named: "background.png")
                }
                
                if cover != "" {
                    self.coverImage.setImage(cover)
                    let red = color["red"]!
                    let green = color["green"]!
                    let blue = color["blue"]!
                    self.cardView.backgroundColor = UIColor.init(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                } else {
                    self.coverImage.image = UIImage(named: "background.png")
                    self.cardView.backgroundColor = .lightGray
                }
                
            }
            else {
                print("ไม่มีข้อมูล")
            }
        }
    }
    
    func getData() {
        db.collection("cafe_reward").document(cafe_id).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.rewardArray.removeAll()
            if document.get("exp_date") != nil {
                let exp_date = document.get("exp_date") as! Timestamp
                let timeFormat = DateFormatter()
                timeFormat.dateFormat = "dd MMM yy"
                let timestamp = timeFormat.string(from: exp_date.dateValue())
                self.expdateLabel.text = "\(timestamp)"
            }
            else {
                self.expdateLabel.text = "ไม่มีกำหนด"
            }
            let conditions = document.get("conditions") as! [String]
            if conditions.count != 0 {
                let bullet = "•  "
                self.strings = conditions
                self.strings = self.strings.map { return bullet + $0 }
                    
                var attributes = [NSAttributedString.Key: Any]()
                attributes[.font] = UIFont(name: "Helvetica Neue", size: 16)
                attributes[.foregroundColor] = UIColor.init(red: 49/255, green: 49/255, blue: 51/255, alpha: 1)
                    
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
                attributes[.paragraphStyle] = paragraphStyle
                paragraphStyle.paragraphSpacing = 2
                paragraphStyle.lineSpacing = 2
                    
                let string = self.strings.joined(separator: "\n")
                self.bulletTextView.attributedText = NSAttributedString(string: string, attributes: attributes)
            } else {
                self.bulletTextView.text = "ไม่มีเงื่อนไข"
            }
                
            let reward = document.get("reward") as! [[String:Any]]
            for rw in reward {
                let point = rw["point"] as! Int
                let reward = rw["reward"] as! String
                let imageURL = rw["reward_imageURL"] as! String
                self.rewardArray.append(RewardData(point: point, reward: reward, reward_imageURL: imageURL))
                self.rewardArray = self.rewardArray.sorted { $0.point < $1.point }
            }
            if self.rewardArray.count > 0 {
                self.table.isHidden = false
                self.table.reloadData()
            } else {
                self.table.isHidden = true
            }
        }
    }
}

extension ShowRewardVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "RewardCell", for: indexPath) as? RewardCell else {
            return UITableViewCell()
        }
        cell.pointLabel.text = "\(rewardArray[indexPath.row].point) แต้ม"
        cell.rewardLabel.text = rewardArray[indexPath.row].reward
        if rewardArray[indexPath.row].reward_imageURL == "" {
            cell.rewardImage.image = logoImage.image
        } else {
            print(rewardArray[indexPath.row].reward_imageURL)
            cell.rewardImage.setImage(rewardArray[indexPath.row].reward_imageURL)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editRewardVC2 = self.storyboard?.instantiateViewController(withIdentifier: "EditRewardVC2") as! EditRewardVC2
        editRewardVC2.rewardData = rewardArray[indexPath.row]
        editRewardVC2.cafe_id = cafe_id
        editRewardVC2.user = "old"
        self.navigationController?.pushViewController(editRewardVC2, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteReward(rewardData: rewardArray[indexPath.row])
            rewardArray.remove(at: indexPath.row)
            table.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteReward(rewardData: RewardData) {
        let data = [
            "point": rewardData.point,
            "reward": rewardData.reward,
            "reward_imageURL": rewardData.reward_imageURL
            ] as [String : Any]
        db.collection("cafe_reward").document(cafe_id).updateData([
            "reward": FieldValue.arrayRemove([data])
            ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully removed!")
                if rewardData.reward_imageURL != "" {
                    let desertRef = Storage.storage().reference(forURL: rewardData.reward_imageURL)
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
}
