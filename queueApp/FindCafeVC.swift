//
//  FindCafeVC.swift
//  queueApp
//
//  Created by Bambam on 27/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase

struct CafeData {
    var cafe_id : String
    var cafename_en : String
    var cafename_th : String
    var type : String
    var location : String
    var imageURL : String
    var rating : Float
}

extension FindCafeVC: RegisterDelegate {
    func register(success: Bool) {
        success1 = success
    }
}

class FindCafeVC: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var clickLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var findViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cafeTableView: UITableView!
    @IBOutlet weak var cafeTableViewHeight: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let gray = UIColor.init(red: 196/255, green: 196/255, blue: 198/255, alpha: 1)
    var cafeArray = [CafeData]()
    var currentCafeArray = [CafeData]()
    var cafeidLabel = UILabel()
    var cnameLabel = UILabel()
    var cafeImgLabel = UILabel()
    var success1 = false
    var delegate: RegisterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupBackButtonNavBar()
        setupSearchTextField()
//        setupCafeCollection()
        getCafeData()
        
        nextButton.layer.cornerRadius = 5
        
        cafeidLabel.text = ""
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSignupVC2))
        clickLabel.isUserInteractionEnabled = true
        clickLabel.addGestureRecognizer(tap)
        nextButton.addTarget(self, action: #selector(openSignupVC1), for: .touchUpInside)
        
        cafeTableView.delegate = self
        cafeTableView.dataSource = self
        cafeTableView.isHidden = true
        cafeTableView.layer.borderColor = gray.cgColor
        cafeTableView.layer.borderWidth = 1
//        warningButton.isHidden = true
//        warningButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
//        warningButton.isUserInteractionEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let cafeHeight = cafeTableView.contentSize.height
        cafeTableViewHeight.constant = cafeHeight
        print(cafeHeight)
        findViewHeight.constant = cafeTableViewHeight.constant + 94
        print(findViewHeight.constant)
        
        if searchTextField.text! == "" {
            findViewHeight.constant = 94
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if success1 == true {
            delegate?.register(success: true)
            performSegueToReturnBack()
            success1 = false
        }
    }
    
    @objc func openSignupVC1() {
        let cafe_id = cafeidLabel.text!
        if cafe_id != "" {
            if searchTextField.text! == cnameLabel.text! {
                let cafe_imageURL = cafeImgLabel.text!
                let signupVC1 = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC1") as! SignupVC1
                signupVC1.cafe_id = cafe_id
                signupVC1.cafe_imageURL = cafe_imageURL
                signupVC1.delegate = self
                self.navigationController?.pushViewController(signupVC1, animated: true)
            }
        }
        else {
            print("มา")
            searchTextField.layer.borderColor = red.cgColor
        }
    }
    
    @objc func openSignupVC2() {
        let signupVC2 = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC2") as! SignupVC2
        signupVC2.delegate = self
        self.navigationController?.pushViewController(signupVC2, animated: true)
    }
    
    func setupSearchTextField() {
        searchTextField.layer.borderColor = gray.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 5
        searchTextField.addImage(image: UIImage(named: "search.png")!)
        
        searchTextField.addTarget(self, action: #selector(searchControl), for: .editingChanged)
    }
    
    func getCafeData() {
        db.collection("cafe").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if document.get("cafename_th") != nil && document.get("area_th") != nil && document.get("area_en") != nil && document.get("type") != nil && document.get("rating") != nil && document.get("ll_location") != nil {
                        let cafe_id = document.get("cafe_id") as! String
                        let cafename_en = document.get("cafename_en") as! String
                        let cafename_th = document.get("cafename_th") as! String
                        let type = document.get("type") as! String
                        let location = document.get("location") as! String
//                        let rating = document.get("rating") as! Float
                        self.cafeArray.append(CafeData(cafe_id: cafe_id, cafename_en: cafename_en, cafename_th: cafename_th, type: type, location: location, imageURL: "", rating: 0))
                    }
                }
                let dispatch = DispatchGroup()
                self.getImageURL(allId: self.cafeArray, dispatch: dispatch){(array) in
                    dispatch.notify(queue: .main, execute: {
                        print("เข้า")
                        self.cafeArray = array
                        self.cafeTableView.reloadData()
                    })
                }
            }
        }
    }
    
    func getImageURL(allId: [CafeData], dispatch:DispatchGroup, completed: @escaping ([CafeData]) -> Void) {
        let arrayLength = allId.count
        var array = allId
        for n in 0..<arrayLength {
            let id = array[n].cafe_id
            let cafeImage = db.collection("cafe_image").document(id)
            dispatch.enter()
            cafeImage.getDocument { (document, err) in
                if let document = document, document.exists {
                    let uurl = document.get("cafe_cover") as! String
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
    
    @objc func searchControl() {
        searchTextField.layer.borderColor = gray.cgColor
        let searchText = searchTextField.text!
        print(searchText)
        currentCafeArray.removeAll()
            
        if searchText == "" || searchText == " " {
            print("Empty Search")
    //      warningButton.isHidden = true
            cafeidLabel.text = ""
            cafeImgLabel.text = ""
            cafeTableView.isHidden = true
            cafeTableView.reloadData()
            return
        }
            
        for data in cafeArray {
            let text = searchText.lowercased()
            let cafename_en_contain = data.cafename_en.lowercased().range(of: text)
                
            currentCafeArray = cafeArray.filter({ cafe -> Bool in
                "\(cafe.cafename_en) \(cafe.cafename_th)".lowercased().contains(searchText.lowercased()) ||
                        cafe.type.lowercased().contains(searchText.lowercased())
            })
                
            if cafename_en_contain == nil {
                cafeTableView.isHidden = true
            }
        }
        cafeTableView.isHidden = false
        print(currentCafeArray)
        currentCafeArray = Array(currentCafeArray.prefix(4))
        cafeTableView.reloadData()
    }

}

extension FindCafeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCafeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = cafeTableView.dequeueReusableCell(withIdentifier: "FindCafeCell", for: indexPath) as? FindCafeCell else {
            return UITableViewCell()
        }
        let data = currentCafeArray[indexPath.item]
        cell.cafenameLabel.text = "\(data.cafename_en) \(data.cafename_th)"
        cell.typeLabel.text = "\(data.type)"
        if data.imageURL != "" {
            cell.cafeImage.setImage(data.imageURL)
        }
        else {
            cell.cafeImage.image = UIImage(named: "background.png")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = currentCafeArray[indexPath.item]
        cafeidLabel.text = data.cafe_id
        cnameLabel.text = "\(data.cafename_en) \(data.cafename_th)"
        cafeImgLabel.text = data.imageURL
        searchTextField.text = "\(data.cafename_en) \(data.cafename_th)"
        currentCafeArray.removeAll()
        cafeTableView.reloadData()
    }
}
