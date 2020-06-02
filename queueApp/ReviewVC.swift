//
//  ReviewVC.swift
//  queueApp
//
//  Created by Bambam on 8/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

struct ReviewData {
    var review_id : String
    var username : String
    var cafename_en : String
    var cafe_id : String
    var rating : Float
    var timeInterval : TimeInterval
    var review_text : String
}

struct ImageURL {
    var id : String
    var imageURL : String
}

class ReviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var reviewCollection: UICollectionView!
    
    var cafe_id = String()
    let cellId = "ShowReviewCollectionViewCell"
    let db = Firestore.firestore()
    var reviewArray = [ReviewData]()
    var imageURL = [ImageURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewCollection.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 241/255, alpha: 1)
        setupBackButtonNavBar()
//        navigationController?.navigationBar.isTranslucent = false
        
        setupCollectionView()
        getDataReview()
    }
    
    private func setupCollectionView() {
        reviewCollection.delegate = self
        reviewCollection.dataSource = self
        let nib = UINib(nibName: "ShowReviewCollectionViewCell", bundle: nil)
        reviewCollection.register(nib, forCellWithReuseIdentifier: cellId)
    }
    
    func getDataReview() {
        let reviewRef = self.db.collection("review").order(by: "time", descending: true)
        reviewRef.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                self.reviewArray.removeAll()
                for doc in snapshot!.documents {
                    let cafe_id1 = doc.get("cafe_id") as! String
                    let cafename_en = doc.get("cafename_en") as! String
                    if self.cafe_id == cafe_id1 {
                        let uid = doc.get("uid") as! String
                        let username = doc.get("username") as! String
                        let rating = doc.get("rating") as! Float
                        let timeInterval = doc.get("timeInterval") as! TimeInterval
                                
                        let review_text = doc.get("review_text") as! String
                                    
                        self.imageURL.append(ImageURL(id: uid, imageURL: ""))
                        self.reviewArray.append(ReviewData(review_id: doc.documentID, username: username, cafename_en: cafename_en, cafe_id: cafe_id1, rating: rating, timeInterval: timeInterval, review_text: review_text))
                    }
                }
                let dispatch = DispatchGroup()
                self.getImageURL(allId: self.imageURL, dispatch: dispatch){(array) in
                    dispatch.notify(queue: .main, execute: {
                        self.imageURL.removeAll()
                        self.imageURL = array
                        self.reviewCollection.reloadData()
                    })
                }
            }
        }
    }
    
    ///เวลาเราจะดึงข้อมูลจาก firestore พอเก็บเข้า array มันจะไม่เรียงให้ตามที่เราต้องการ ก็เลยต้องมีตัวกำกับหนึ่งอัน อย่าง userid: แล้วก็อยากจะเพิ่มค่าอะไรก็เพิ่มในเข้าไปในตัวที่สอง ก็คือ imageURL : เพิ่มเข้าไปตรงๆแทนการ append เพราะ append แล้วเละค่ะมันไม่เรียงให้น้องค่ะ
    func getImageURL(allId: [ImageURL], dispatch:DispatchGroup, completed: @escaping ([ImageURL]) -> Void) {
        let arrayLength = allId.count
        var array = allId
        for n in 0..<arrayLength {
            let id = array[n].id
            let user = db.collection("user").document(id)
            dispatch.enter()
            user.getDocument { (document, err) in
                if let document = document, document.exists {
                    let uurl = document.get("user_imageURL") as! String
                    array[n].imageURL = uurl
                } else {
                    print("Document does not exist")
                }
                dispatch.leave()
            }
        }
        dispatch.notify(queue: .main, execute: {
            completed(array)
        })
    }
    
    public func changeAllStarRateToImage(rating : Float) -> UIImage {
        var rateImage = UIImage()
        switch rating {
        case 1.0:
            rateImage = UIImage(named: "star11.png")!
            return rateImage
        case 2.0:
            rateImage = UIImage(named: "star22.png")!
            return rateImage
        case 3.0:
            rateImage = UIImage(named: "star33.png")!
            return rateImage
        case 4.0:
            rateImage = UIImage(named: "star44.png")!
            return rateImage
        default:
            rateImage = UIImage(named: "star55.png")!
            return rateImage
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let user = reviewArray[indexPath.item] as? ReviewData {
            let approximateWidthOfReviewTextView = view.frame.width - 78
            let size = CGSize(width: approximateWidthOfReviewTextView, height: 1000)
            let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)]
            let estimatedFrame = NSString(string: user.review_text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 85)
        }
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ShowReviewCollectionViewCell else {
            return UICollectionViewCell()
        }
        let username = reviewArray[indexPath.item].username
        cell.textReview.text = reviewArray[indexPath.item].review_text
        cell.starRate.image = changeAllStarRateToImage(rating: reviewArray[indexPath.item].rating)
        cell.userName.text = username
        
        //format date
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "MMM d, HH:mm"
        let timestamp = timeFormat.string(from: Date(timeIntervalSinceReferenceDate: reviewArray[indexPath.item].timeInterval))
        cell.timeReview.text = timestamp
        
        if imageURL[indexPath.item].imageURL != "" {
            cell.userImage.setImage(imageURL[indexPath.item].imageURL)
        }
        else {
            cell.userImage.image = UIImage(named: "background.png")
        }
        return cell
    }

}


