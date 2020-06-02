//
//  QueueListVC.swift
//  queueApp
//
//  Created by Bambam on 20/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

struct Queue {
    var queue_id : String
    var queue_no : String
    var uid : String
    var username : String
    var imageURL : String
    var timeInterval : Double
}

struct CreateQueue {
    var queue_no: String
    var time: Double
}

struct MyQueue {
    var queue_id: String
    var queue_no: String
    var number_people: Int
    var wait_queue: Int
    var cafe_id: String
    var logoURL: String
    var timeInterval: Double
    var status: String
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
class QueueListVC: UIViewController {
    
    @IBOutlet weak var queueTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var openPopupButton: UIButton!
    
    //popup
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var addNumberButton: UIButton!
    @IBOutlet weak var minusNumberButton: UIButton!
    @IBOutlet weak var addQueueButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupViewBackgroundView: UIView!
    @IBOutlet weak var closePopupButton: UIButton!
    
    //show queue number
    @IBOutlet weak var showQueueNumberView: UIView!
    @IBOutlet weak var queueNumberLabel: UILabel!
    @IBOutlet weak var okayButton: UIButton!
    
    let db = Firestore.firestore()
    var queueArray = [Queue]()
    var currentQueueArray = [Queue]()
    var category = [String]()
    let grayColor = UIColor.init(red: 196/255, green: 196/255, blue: 198/255, alpha: 1)
    let redColor = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let greenColor = UIColor.init(red: 90/255, green: 100/255, blue: 50/255, alpha: 1)
    let yellowColor = UIColor.init(red: 206/255, green: 139/255, blue: 78/255, alpha: 1)
    let creamColor = UIColor.init(red: 197/255, green: 152/255, blue: 104/255, alpha: 1)
    var colorCategory = [UIColor]()
    var arrayA = [Queue]()
    var arrayB = [Queue]()
    var arrayC = [Queue]()
    var arrayD = [Queue]()
    var cafe_id = String()
    var user = ""
    var number = 1
    var cafenameLabel = UILabel()
    var queueDataArray = [CreateQueue]()
    var sortedArray = [CreateQueue]()
    var vSpinner : UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserToSetBack()
        category = ["A", "B", "C", "D"]
        colorCategory = [redColor, greenColor, yellowColor, creamColor]
        queueTableView.delegate = self
        queueTableView.dataSource = self
        setTimeButton()
        getTotalQueue()
        getQueueListData()
        openPopupButton.layer.cornerRadius = 15
        openPopupButton.addTarget(self, action: #selector(openPopup), for: .touchUpInside)
        
        //popup
        numberLabel.text = "\(number)"
        popupView.layer.cornerRadius = 15
        popupViewBackgroundView.isHidden = true
        addQueueButton.layer.cornerRadius = 15
        addNumberButton.layer.cornerRadius = addNumberButton.bounds.height / 2
        minusNumberButton.layer.cornerRadius = minusNumberButton.bounds.height / 2
        minusNumberButton.layer.borderColor = redColor.cgColor
        minusNumberButton.layer.borderWidth = 1
        addQueueButton.addTarget(self, action: #selector(bookQueue), for: .touchUpInside)
        addNumberButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        minusNumberButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        closePopupButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        
        okayButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        showQueueNumberView.isHidden = true
        showQueueNumberView.layer.cornerRadius = 15
        okayButton.layer.cornerRadius = 15
    }
    
//MARK: - Pop up
    
    @objc func openPopup() {
        animateIn()
    }
    
    @objc func closePopup() {
        animateOut()
    }
        
    func animateIn() {
        self.view.addSubview(popupView)
        popupView.center = self.view.center
        popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popupView.alpha = 0
        popupViewBackgroundView.isHidden = true
            
        UIView.animate(withDuration: 0.4) {
            self.popupView.alpha = 1
            self.popupViewBackgroundView.isHidden = false
            self.popupView.transform = CGAffineTransform.identity
        }
    }
            
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.showQueueNumberView.isHidden = true
            self.popupView.alpha = 0
            self.popupViewBackgroundView.isHidden = true
            self.popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        }) { (success:Bool) in
            self.popupView.removeFromSuperview()
        }
    }
    
    @objc func plus() {
        if number < 8 {
            number+=1
            numberLabel.text = "\(number)"
        }
    }
    
    @objc func minus() {
        if number > 1 {
            number-=1
            numberLabel.text = "\(number)"
        }
    }
    
    @objc func bookQueue() {
        print(number)
        var categoryArray = [String]()
        var queue_no = String()
        let cafename_en = cafenameLabel.text ?? ""
        let category = tableCategory(number: number)
        queueDataArray.removeAll()
        db.collection("queue").whereField("cafe_id", isEqualTo: cafe_id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.loading(self.view)
                if querySnapshot!.documents.count != 0 { //ข้อมูลไม่เท่ากับ 0
                    for document in querySnapshot!.documents {
                        let cate = document.get("queue_no") as! String
                        let time = document.get("timeInterval") as! Double
                        if cate.contains(category) { //มี A B C D อยู่ใน string
                            self.queueDataArray.append(CreateQueue(queue_no: cate, time: time))
                        }
                    }
                    if self.queueDataArray.count != 0 { //มี A B C D อยู่ใน string ค่าใน array ไม่เท่ากับ 0
                        self.sortedArray = self.queueDataArray.sorted { $0.time < $1.time }
                        let last = self.sortedArray.last!
                        print("last of category = \(last)")
                        let seperateLast = last.queue_no.components(separatedBy: category)
                        var last_no = Int(seperateLast[1])!
                        if last_no == 99 { //ถ้าบัตรคิวถึงเลข 99 อันต่อไปจะเซ็ตให้กลับไปเป็น 0
                            last_no = 0
                        }
                        queue_no = "\(category)\(String(format: "%02d", last_no+1))"
                        print(queue_no)
                    }
                    else { //ไม่มี A B C D อยู่ใน string ค่าใน array เป็น 0
                        print("ไม่มีคิวที่มี \(category) นำหน้า")
                        queue_no = "\(category)01"
                        print(queue_no)
                    }
                }
                else { //ยังไม่มีคิวของร้านคาเฟ่นี้ๆ
                    print("ไม่มีคิวเลย")
                    queue_no = "\(category)01"
                    print(queue_no)
                }
                let time = Date().timeIntervalSinceReferenceDate
                let data = [
                    "queue_no": queue_no,
                    "uid": "guest",
                    "cafe_id": self.cafe_id,
                    "cafename_en": cafename_en,
                    "number_people": self.number,
                    "createdate": FieldValue.serverTimestamp(),
                    "timeInterval": time,
                    "status": "booked"
                ] as [String : Any]

                //add queue data to collection-queue
                var ref: DocumentReference? = nil
                ref = self.db.collection("queue").addDocument(data: data) { err in
                    if let err = err {
                        print("Error adding queue: \(err)")
                    } else {
                        print("Queue added with ID: \(ref!.documentID)")
                        let queueRef = self.db.collection("queue").document(ref!.documentID)
                        queueRef.updateData([
                            "queue_id" : "\(ref!.documentID)"
                        ]) { er in
                            if let er = er {
                                print("Error updating queue: \(er)")
                            } else {
                                print("Queue successfully updated")
                                self.showQueueNumberView.isHidden = false
                                self.queueNumberLabel.text = queue_no
                                self.addQueueToCafeData()
                                self.removeLoading()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addQueueToCafeData() {
        number = 1
        numberLabel.text = "\(number)"
        db.collection("queue").whereField("cafe_id", isEqualTo: cafe_id).whereField("status", isEqualTo: "booked")
        .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            let cafeRef = self.db.collection("cafe").document(self.cafe_id)
            cafeRef.updateData([
                "queue": documents.count
            ]) { err in
                if let err = err {
                    print("Error updating queue to cafe: \(err)")
                } else {
                    print("Queue successfully updated to cafe")
                }
            }
        }
    }
    
    func tableCategory(number: Int) -> String {
        var category = ""
        if number <= 2 {
            category = "A"
        }
        else if number > 2 && number <= 4 {
            category = "B"
        }
        else if number > 4 && number <= 6 {
            category = "C"
        }
        else {
            category = "D"
        }
        return category
    }
    
    func setTimeButton() {
        timeButton.addTarget(self, action: #selector(openTimeVC), for: .touchUpInside)
        db.collection("cafe").document(cafe_id).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let cafename_en = document.get("cafename_en") as! String
            self.cafenameLabel.text = cafename_en
            let booking_time = document.get("booking_time") as! [String: Any]
            let today = self.getCurrentWeekday()
            if booking_time["\(today)"] != nil {
                print("มี")
                let time = booking_time["\(today)"] as! String
                if time == "หยุด" {
                    self.timeButton.setTitleColor(self.redColor, for: .normal)
                    self.timeButton.setTitle("วันนี้ร้านปิดรับคิว  >", for: .normal)
                    self.openPopupButton.isEnabled = false
                    self.openPopupButton.backgroundColor = self.grayColor
                } else {
                    let strArray = time.components(separatedBy: " - ")
                    let opening = strArray[0]
                    let closing = strArray[1]
                    let now = Date()
                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone.current
                    formatter.dateFormat = "HH:mm"
                    let dateString = formatter.string(from: now)
                    if dateString >= opening && dateString <= closing {
                        self.timeButton.setTitleColor(self.greenColor, for: .normal)
                        self.timeButton.setTitle("ร้านเปิดรับคิว \(time)  >", for: .normal)
                        self.openPopupButton.isEnabled = true
                        self.openPopupButton.backgroundColor = self.redColor
                    } else {
                        self.timeButton.setTitleColor(self.redColor, for: .normal)
                        self.timeButton.setTitle("ร้านปิดรับคิว  >", for: .normal)
                        self.openPopupButton.isEnabled = false
                        self.openPopupButton.backgroundColor = self.grayColor
                    }
                }
            } else {
                print("ไม่มี")
                self.timeButton.setTitleColor(self.redColor, for: .normal)
                self.timeButton.setTitle("วันนี้ร้านปิดรับคิว  >", for: .normal)
                self.openPopupButton.isEnabled = false
                self.openPopupButton.backgroundColor = self.grayColor
            }
           
        }
    }
    
    func getCurrentWeekday() -> String {
        var weekdayString = String()
        let date = Date()
        let calender = Calendar.current
        let currentWeekday = calender.component(.weekday, from: date)
        switch currentWeekday {
        case 1:
            weekdayString = "Sunday"
        case 2:
            weekdayString = "Monday"
        case 3:
            weekdayString = "Tuesday"
        case 4:
            weekdayString = "Wednesday"
        case 5:
            weekdayString = "Thursday"
        case 6:
            weekdayString = "Friday"
        case 7:
            weekdayString = "Saturday"
        default:
            print("Error fetching days")
            weekdayString = "Day"
        }
        return weekdayString
    }
    
    @objc func openTimeVC() {
        let timeVC = self.storyboard?.instantiateViewController(withIdentifier: "TimeVC") as! TimeVC
        timeVC.cafe_id = cafe_id
        timeVC.from = "changebookingtime"
        self.navigationController?.pushViewController(timeVC, animated: true)
    }
    
    func checkUserToSetBack() {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back_red.png"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 28)
        if user == "new" {
            backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        } else {
            backButton.addTarget(self, action: #selector(backToPrevious), for: .touchUpInside)
        }
        let menuBarItem = UIBarButtonItem(customView: backButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 40)
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        currHeight?.isActive = true
        
        navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTotalQueue() {
        db.collection("queue").whereField("cafe_id", isEqualTo: cafe_id).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            var reviewTotal = [String]()
            for doc in documents {
                let cafe_id = doc.get("cafe_id") as! String
                let status = doc.get("status") as! String
                if status == "booked" || status == "called" {
                    reviewTotal.append(cafe_id)
                }
            }
            self.totalLabel.text = "คิวทั้งหมด \(reviewTotal.count) คิว"
        }
    }
        
    func getQueueListData() {
        print("เข้า")
        db.collection("queue").whereField("cafe_id", isEqualTo: cafe_id).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.arrayA.removeAll()
            self.arrayB.removeAll()
            self.arrayC.removeAll()
            self.arrayD.removeAll()
            self.queueArray.removeAll()
            self.currentQueueArray.removeAll()
            for doc in documents {
                let queue_id = doc.documentID
                let queue_no = doc.get("queue_no") as! String
                let uid = doc.get("uid") as! String
                let status = doc.get("status") as! String
                let timeInterval = doc.get("timeInterval") as! Double
                if status == "booked" || status == "called" {
                    if queue_no.contains("A") {
                        self.arrayA.append(Queue(queue_id: queue_id, queue_no: queue_no, uid: uid, username: "", imageURL: "", timeInterval: timeInterval))
                        print("A = \(queue_no)")
                    }
                    else if queue_no.contains("B") {
                        self.arrayB.append(Queue(queue_id: queue_id, queue_no: queue_no, uid: uid, username: "", imageURL: "", timeInterval: timeInterval))
                        print("B = \(queue_no)")
                    }
                    else if queue_no.contains("C") {
                        self.arrayC.append(Queue(queue_id: queue_id, queue_no: queue_no, uid: uid, username: "", imageURL: "", timeInterval: timeInterval))
                        print("C = \(queue_no)")
                    }
                    else if queue_no.contains("D") {
                        self.arrayD.append(Queue(queue_id: queue_id, queue_no: queue_no, uid: uid, username: "", imageURL: "", timeInterval: timeInterval))
                        print("D = \(queue_no)")
                    }
                }
            }
            self.arrayA = self.arrayA.sorted { $0.timeInterval < $1.timeInterval }
            self.arrayB = self.arrayB.sorted { $0.timeInterval < $1.timeInterval }
            self.arrayC = self.arrayC.sorted { $0.timeInterval < $1.timeInterval }
            self.arrayD = self.arrayD.sorted { $0.timeInterval < $1.timeInterval }
            self.queueTableView.reloadData()
            
//            self.totalLabel.text = "Totol = \(self.queueArray.count)"
//            let dispatch = DispatchGroup()
//            self.getUserData(allQueue: self.queueArray, dispatch: dispatch) {(array) in
//                dispatch.notify(queue: .main, execute: {
//                    self.queueArray = array
//                    self.currentQueueArray = self.queueArray.sorted { $0.timeInterval < $1.timeInterval }
//                    self.queueCollectionView.reloadData()
//                })
//            }
        }
    }
    
    func getUserData(allQueue: [Queue], dispatch:DispatchGroup, completed: @escaping ([Queue]) -> Void) {
        let arrayLength = allQueue.count
        var array = allQueue
        for n in 0..<arrayLength {
            let uid = array[n].uid
            let userRef = db.collection("user").document(uid)
            dispatch.enter()
            userRef.getDocument { (document, err) in
                if let document = document, document.exists {
                    let username = document.get("username") as! String
                    let url = document.get("user_imageURL") as! String
                    array[n].imageURL = url
                    array[n].username = username
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
    
}

extension QueueListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = queueTableView.dequeueReusableCell(withIdentifier: "QueueListCell", for: indexPath) as? QueueListCell else {
            return UITableViewCell()
        }
        if indexPath.item == 0 {
            cell.categoryLabel1.text = "A"
            cell.categoryLabel2.text = "1-2 คน"
            cell.categoryView.backgroundColor = colorCategory[0]
            cell.queueNumberLabel.text = ""
            cell.callButton.isHidden = true
            if arrayA.count > 0 {
                let data = arrayA[0]
                cell.data = data
                cell.queueNumberLabel.text = data.queue_no
                cell.callButton.isHidden = false
                print("A \(data.queue_no)")
            }
        }
        else if indexPath.item == 1 {
            cell.categoryLabel1.text = "B"
            cell.categoryLabel2.text = "3-4 คน"
            cell.categoryView.backgroundColor = colorCategory[1]
            cell.queueNumberLabel.text = ""
            cell.callButton.isHidden = true
            if arrayB.count > 0 {
                let data = arrayB[0]
                cell.data = data
                cell.queueNumberLabel.text = data.queue_no
                cell.callButton.isHidden = false
                print("B \(data.queue_no)")
            }
        }
        else if indexPath.item == 2 {
            cell.categoryLabel1.text = "C"
            cell.categoryLabel2.text = "5-6 คน"
            cell.categoryView.backgroundColor = colorCategory[2]
            cell.queueNumberLabel.text = ""
            cell.callButton.isHidden = true
            if arrayC.count > 0 {
                let data = arrayC[0]
                cell.data = data
                cell.queueNumberLabel.text = data.queue_no
                cell.callButton.isHidden = false
                print("C \(data.queue_no)")
            }
        }
        else if indexPath.item == 3 {
            cell.categoryLabel1.text = "D"
            cell.categoryLabel2.text = "7-8 คน"
            cell.categoryView.backgroundColor = colorCategory[3]
            cell.queueNumberLabel.text = ""
            cell.callButton.isHidden = true
            if arrayD.count > 0 {
                let data = arrayD[0]
                cell.data = data
                cell.queueNumberLabel.text = data.queue_no
                cell.callButton.isHidden = false
                print("D \(data.queue_no)")
            }
        }
        return cell
    }
}

extension QueueListVC {
    
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

