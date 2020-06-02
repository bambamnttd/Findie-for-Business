//
//  TimeVC.swift
//  queueApp
//
//  Created by Bambam on 2/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

struct MyDayTime {
    var day: String
    var time: String
    var no: Int
}

class TimeVC: UIViewController {
    
    @IBOutlet weak var dayCollection: UICollectionView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var openTextField: UITextField!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var closeTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var notimeView: UIView!
    @IBOutlet weak var timeTable: UITableView!
    @IBOutlet weak var titleVCLabel: UILabel!
    
    let db = Firestore.firestore()
    var dayArray = [String]()
    var daySelectedIndex = [IndexPath]()
    var daySelectedData = [String]()
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let green = UIColor.init(red: 90/255, green: 100/255, blue: 50/255, alpha: 1)
    let cream = UIColor.init(red: 192/255, green: 151/255, blue: 118/255, alpha: 1)
    let yellow = UIColor.init(red: 204/255, green: 139/255, blue: 79/255, alpha: 1)
    let gray = UIColor.init(red: 138/255, green: 138/255, blue: 142/255, alpha: 1)
    let lightgray = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    var timeOptions = [String]()
    var colorArray = [UIColor]()
    var cafe_id = String()
    var myDayArray = [MyDayTime]()
    var opening_time = [String: String]()
    var vSpinner: UIView?
    var from = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButtonNavBar()
        setTextField()
        setPickerView()
        timeTable.delegate = self
        timeTable.dataSource = self
        dayCollection.dataSource = self
        dayCollection.delegate = self
        dayCollection.allowsMultipleSelection = true
        bgView.layer.cornerRadius = 30
        addButton.addTarget(self, action: #selector(addTime), for: .touchUpInside)
        addButton.layer.cornerRadius = 15

        dayArray = ["จ", "อ", "พ","พฤ", "ศ", "ส", "อา"]
        timeOptions = ["หยุด", "00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:59"]
        colorArray = [cream, red, green, yellow, cream, green, red]
        
        if from == "infolist" {
            getOpeningTime()
            titleVCLabel.text = "เวลาเปิด - ปิดร้าน"
        } else {
            getBookingTime()
            titleVCLabel.text = "เวลาเปิด - ปิดรับคิว"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(row: 0, section: 0)
        dayCollection.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        let cell = dayCollection.cellForItem(at: indexPath) as! DayCell
        cell.dayView.backgroundColor = cream
        cell.dayLabel.textColor = .white
        daySelectedData.append(dayArray[indexPath.item])
        daySelectedIndex.append(indexPath)
    }
    
    func deselectDay() {
        for index in daySelectedIndex {
            dayCollection.deselectItem(at: index, animated: true)
            let cell = dayCollection.cellForItem(at: index) as! DayCell
            cell.dayView.backgroundColor = .white
            cell.dayLabel.textColor = gray
        }
        daySelectedIndex.removeAll()
        daySelectedData.removeAll()
    }
    
    func setTextField() {
        openTextField.setBackground()
        closeTextField.setBackground()
    }
    
    func setPickerView() {
        let pickerView1 = UIPickerView()
        pickerView1.delegate = self
        pickerView1.backgroundColor = lightgray
        pickerView1.tag = 1
        openTextField.inputView = pickerView1
        
        let pickerView2 = UIPickerView()
        pickerView2.delegate = self
        pickerView2.backgroundColor = lightgray
        pickerView2.tag = 2
        closeTextField.inputView = pickerView2
    }
    
    @objc func addTime() {
        if from == "infolist" {
            if daySelectedData.count != 0 {
                if openTextField.text != "" && closeTextField.text != "" {
                    loading(self.view)
                    let open = openTextField.text!
                    let close = closeTextField.text!
                    print(daySelectedData)
                    for myday in myDayArray {
                        let my = changeDayThaiToEng(day_th: myday.day)
                        self.opening_time["\(my)"] = myday.time
                    }
                    for day in daySelectedData {
                        let d = changeToFullWord(day: day)
                        self.opening_time["\(d)"] = "\(open) - \(close)"
                    }
                    self.myDayArray.removeAll()
                    self.db.collection("cafe").document(cafe_id).updateData([
                        "opening_time": self.opening_time
                        ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            self.openTextField.text = ""
                            self.closeTextField.text = ""
                            self.deselectDay()
                            let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
                else if openTextField.text == "หยุด" {
                    loading(self.view)
                    print(daySelectedData)
                    for myday in myDayArray {
                        let my = changeDayThaiToEng(day_th: myday.day)
                        self.opening_time["\(my)"] = myday.time
                    }
                    for day in daySelectedData {
                        let d = changeToFullWord(day: day)
                        self.opening_time["\(d)"] = "หยุด"
                    }
                    self.myDayArray.removeAll()
                    self.db.collection("cafe").document(cafe_id).updateData([
                        "opening_time": self.opening_time
                        ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            self.openTextField.text = ""
                            self.closeTextField.text = ""
                            self.closeTextField.isHidden = false
                            self.closeLabel.isHidden = false
                            self.deselectDay()
                            let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
        else {
            print(myDayArray)
            if daySelectedData.count != 0 {
                if openTextField.text != "" && closeTextField.text != "" {
                    loading(self.view)
                    let open = openTextField.text!
                    let close = closeTextField.text!
                    print(daySelectedData)
                    for myday in myDayArray {
                        let my = changeDayThaiToEng(day_th: myday.day)
                        self.opening_time["\(my)"] = myday.time
                    }
                    for day in daySelectedData {
                        let d = changeToFullWord(day: day)
                        self.opening_time["\(d)"] = "\(open) - \(close)"
                //                for myday in myDayArray {
                //                    let my = (day: myday)
                //                }
                    }
                    self.myDayArray.removeAll()
                    self.db.collection("cafe").document(cafe_id).updateData([
                        "booking_time": self.opening_time,
                        "booking": true
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            self.openTextField.text = ""
                            self.closeTextField.text = ""
                            self.daySelectedData.removeAll()
                            let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                
                                if self.from == "changebookingtime" {
                                    self.performSegueToReturnBack()
                                } else {
                                    let queueListVC = self.storyboard?.instantiateViewController(withIdentifier: "QueueListVC") as! QueueListVC
                                    queueListVC.user = "new"
                                    queueListVC.cafe_id = self.cafe_id
                                    self.navigationController?.pushViewController(queueListVC, animated: true)
                                }
                        
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                } else if openTextField.text == "หยุด" {
                    loading(self.view)
                    print(daySelectedData)
                    for myday in myDayArray {
                        let my = changeDayThaiToEng(day_th: myday.day)
                        self.opening_time["\(my)"] = myday.time
                    }
                    for day in daySelectedData {
                        let d = changeToFullWord(day: day)
                        self.opening_time["\(d)"] = "หยุด"
                    }
                    self.myDayArray.removeAll()
                    self.db.collection("cafe").document(cafe_id).updateData([
                        "booking_time": self.opening_time,
                        "booking": true
                        ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.removeLoading()
                            self.openTextField.text = ""
                            self.closeTextField.text = ""
                            self.closeTextField.isHidden = false
                            self.closeLabel.isHidden = false
                            self.deselectDay()
                            let alert = UIAlertController(title: "บันทึกสำเร็จ", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
                                if self.from == "changebookingtime" {
                                    self.performSegueToReturnBack()
                                } else {
                                    let queueListVC = self.storyboard?.instantiateViewController(withIdentifier: "QueueListVC") as! QueueListVC
                                    queueListVC.user = "new"
                                    queueListVC.cafe_id = self.cafe_id
                                    self.navigationController?.pushViewController(queueListVC, animated: true)
                                }
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func getOpeningTime() {
        db.collection("cafe").document(cafe_id).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.myDayArray.removeAll()
            if document.get("opening_time") != nil {
                let timeArray = document.get("opening_time") as! [String : String]
                if timeArray.count == 0 {
                    self.timeTable.isHidden = true
                }
                else {
                    self.timeTable.isHidden = false
                    for (day, time) in timeArray {
                        let day_th = self.changeDayEngToThai(day_en: day)
                        let day_no = self.changeDayToNumber(day: day)
                        self.myDayArray.append(MyDayTime(day: day_th, time: time, no: day_no))
                        self.myDayArray = self.myDayArray.sorted { $0.no < $1.no }
                    }
                }
            }
            else {
                self.timeTable.isHidden = true
            }
            self.timeTable.reloadData()
        }
    }
    
    func getBookingTime() {
        db.collection("cafe").document(cafe_id).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.myDayArray.removeAll()
            if document.get("booking_time") != nil {
                let timeArray = document.get("booking_time") as! [String : String]
                if timeArray.count == 0 {
                    self.timeTable.isHidden = true
                }
                else {
                    self.timeTable.isHidden = false
                    for (day, time) in timeArray {
                        let day_th = self.changeDayEngToThai(day_en: day)
                        let day_no = self.changeDayToNumber(day: day)
                        self.myDayArray.append(MyDayTime(day: day_th, time: time, no: day_no))
                        self.myDayArray = self.myDayArray.sorted { $0.no < $1.no }
                    }
                }
            }
            else {
                self.timeTable.isHidden = true
            }
            self.timeTable.reloadData()
        }
    }
    
    func changeDayEngToThai(day_en: String) -> String {
        switch day_en {
        case "Sunday":
            return "อาทิตย์"
        case "Monday":
            return "จันทร์"
        case "Tuesday":
            return "อังคาร"
        case "Wednesday":
            return "พุธ"
        case "Thursday":
            return "พฤหัสบดี"
        case "Friday":
            return "ศุกร์"
        case "Saturday":
            return "เสาร์"
        default:
            return ""
        }
    }
    
    func changeDayThaiToEng(day_th: String) -> String {
        switch day_th {
        case "อาทิตย์":
            return "Sunday"
        case "จันทร์":
            return "Monday"
        case "อังคาร":
            return "Tuesday"
        case "พุธ":
            return "Wednesday"
        case "พฤหัสบดี":
            return "Thursday"
        case "ศุกร์":
            return "Friday"
        case "เสาร์":
            return "Saturday"
        default:
            return ""
        }
    }
    
    func changeDayToNumber(day: String) -> Int {
        switch day {
        case "Sunday":
            return 6
        case "Monday":
            return 0
        case "Tuesday":
            return 1
        case "Wednesday":
            return 2
        case "Thursday":
            return 3
        case "Friday":
            return 4
        case "Saturday":
            return 5
        default:
            return 7
        }
    }
    
    func changeToFullWord(day: String) -> String {
        switch day {
        case "อา":
            return "Sunday"
        case "จ":
            return "Monday"
        case "อ":
            return "Tuesday"
        case "พ":
            return "Wednesday"
        case "พฤ":
            return "Thursday"
        case "ศ":
            return "Friday"
        case "ส":
            return "Saturday"
        default:
            return ""
        }
    }

}

extension TimeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            openTextField.text = timeOptions[row]
            if openTextField.text == "หยุด" {
                closeTextField.isHidden = true
                closeLabel.isHidden = true
            } else {
                closeTextField.isHidden = false
                closeLabel.isHidden = false
            }
        }
        else {
            closeTextField.text = timeOptions[row]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension TimeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dayCollection.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as? DayCell else {
            return UICollectionViewCell()
        }
        cell.dayLabel.text = dayArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = dayCollection.cellForItem(at: indexPath) as! DayCell
        cell.dayLabel.textColor = .white
        cell.dayView.backgroundColor = colorArray[indexPath.item]
        daySelectedData.append(dayArray[indexPath.item])
        daySelectedIndex.append(indexPath)
        print(daySelectedData)
        print(daySelectedIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = dayCollection.cellForItem(at: indexPath) as! DayCell
        cell.dayLabel.textColor = UIColor.init(red: 138/255, green: 138/255, blue: 142/255, alpha: 1)
        cell.dayView.backgroundColor = .white
        if let index = daySelectedData.firstIndex(of: dayArray[indexPath.item]) {
            daySelectedData.remove(at: index)
            daySelectedIndex.remove(at: index)
        }
    }
    
}

extension TimeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDayArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = timeTable.dequeueReusableCell(withIdentifier: "TimeCell", for: indexPath) as? TimeCell else {
            return UITableViewCell()
        }
        print(myDayArray[indexPath.row])
        cell.dayLabel.text = myDayArray[indexPath.row].day
        cell.timeLabel.text = myDayArray[indexPath.row].time
        cell.colorView.backgroundColor = colorArray[indexPath.row]
        return cell
    }
}

extension TimeVC {
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

