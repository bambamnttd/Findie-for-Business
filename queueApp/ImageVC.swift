//
//  ImageVC.swift
//  queueApp
//
//  Created by Bambam on 2/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ImageVC: UIViewController {
    
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var menuCollection: UICollectionView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    lazy var deleteBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItem))
        return barButtonItem
    }()
    
    lazy var backBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "back_red.png"), style: .plain, target: self, action: #selector(backToPrevious))
        return barButtonItem
    }()
    
    var cafe_id = String()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let red = UIColor.init(red: 213/255, green: 103/255, blue: 82/255, alpha: 1)
    let lightgray = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    let gray = UIColor.init(red: 108/255, green: 108/255, blue: 108/255, alpha: 1)
    var imageArray = [String]()
    var menuArray = [String]()
    var tap = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButtonNavBar()
        setupTabButton()
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.navigationBar.tintColor = red
        setupCollectionView()
        getImage()
        addButton.addTarget(self, action: #selector(openAddImageVC), for: .touchUpInside)
    }
    
    func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    @objc func deleteItem() {
        if imageButton.backgroundColor == red {
            if let selectedCells = imageCollection.indexPathsForSelectedItems {
                let items = selectedCells.map { $0.item }.sorted().reversed()
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let phoneCallAction = UIAlertAction(title: "ลบรูปภาพ \(items.count) รูป", style: .default) { (action) in
                    for item in items {
                        let t = self.imageArray[item]
                        self.db.collection("cafe_image").document(self.cafe_id).updateData([
                            "cafe_image": FieldValue.arrayRemove([t])
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                let imageRef = self.storage.reference(forURL: t)
                                imageRef.delete { error in
                                    if let error = error {
                                        print("error")
                                    } else {
                                        print("Delete image successfully")
                                    }
                                }
                            }
                        }
                    }
                    self.imageCollection.deleteItems(at: selectedCells)
                    self.setupBackButtonNavBar()
                }
                optionMenu.addAction(phoneCallAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                optionMenu.addAction(cancelAction)
                    
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
        
        else {
            if let selectedCells = menuCollection.indexPathsForSelectedItems {
                let items = selectedCells.map { $0.item }.sorted().reversed()
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let phoneCallAction = UIAlertAction(title: "ลบรูปภาพ \(items.count) รูป", style: .default) { (action) in
                    for item in items {
                        let t = self.menuArray[item]
                        self.db.collection("cafe_image").document(self.cafe_id).updateData([
                            "cafe_menu": FieldValue.arrayRemove([t])
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                let imageRef = self.storage.reference(forURL: t)
                                imageRef.delete { error in
                                    if let error = error {
                                        print("error")
                                    } else {
                                        print("Delete image successfully")
                                    }
                                }
                            }
                        }
                    }
                    self.menuCollection.deleteItems(at: selectedCells)
                    self.setupBackButtonNavBar()
                }
                optionMenu.addAction(phoneCallAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                optionMenu.addAction(cancelAction)
                    
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
    }
    
    @objc func openAddImageVC() {
        let addImageVC = self.storyboard?.instantiateViewController(withIdentifier: "AddImageVC") as! AddImageVC
        let navController = UINavigationController(rootViewController: addImageVC)
        addImageVC.cafe_id = cafe_id
        addImageVC.tap = tap
        navController.modalPresentationStyle = .fullScreen
        addImageVC.modalPresentationStyle = .fullScreen
        self.present(navController, animated:true, completion: nil)
    }
    
    func setupTabButton() {
        imageButton.layer.cornerRadius = imageButton.bounds.height / 2
        menuButton.layer.cornerRadius = menuButton.bounds.height / 2
        imageButton.addTarget(self, action: #selector(tapImage), for: .touchUpInside)
        imageButton.setTitleColor(.white, for: .normal)
        imageButton.backgroundColor = red
        menuButton.setTitleColor(gray, for: .normal)
        menuButton.backgroundColor = lightgray
        menuButton.addTarget(self, action: #selector(tapMenu), for: .touchUpInside)
        tap = "image"
    }
    
    func setupCollectionView() {
        let nib = UINib(nibName: "ImageCell", bundle: nil)
        imageCollection.dataSource = self
        imageCollection.delegate = self
        menuCollection.dataSource = self
        menuCollection.delegate = self
        
        imageCollection.isHidden = false
        imageCollection.register(nib, forCellWithReuseIdentifier: "ImageCell")
        imageCollection.backgroundColor = .white
        
        menuCollection.isHidden = true
        menuCollection.register(nib, forCellWithReuseIdentifier: "ImageCell")
        menuCollection.backgroundColor = .white
        
        imageCollection.tag = 1
        menuCollection.tag = 2
        
        let alignedFlowLayout1 = imageCollection?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout1?.horizontalAlignment = .left
        alignedFlowLayout1?.verticalAlignment = .top
        alignedFlowLayout1?.minimumInteritemSpacing = 1
        alignedFlowLayout1?.minimumLineSpacing = 1
        
        let alignedFlowLayout2 = menuCollection?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout2?.horizontalAlignment = .left
        alignedFlowLayout2?.verticalAlignment = .top
        alignedFlowLayout2?.minimumInteritemSpacing = 1
        alignedFlowLayout2?.minimumLineSpacing = 1
    }
    
    @objc func tapImage() {
        if imageButton.backgroundColor == lightgray {
            imageButton.setTitleColor(.white, for: .normal)
            imageButton.backgroundColor = red
            
            imageCollection.isHidden = false
            menuCollection.isHidden = true
            
            menuButton.setTitleColor(gray, for: .normal)
            menuButton.backgroundColor = lightgray
            tap = "image"
        }
    }
    
    @objc func tapMenu() {
        if menuButton.backgroundColor == lightgray {
            menuButton.setTitleColor(.white, for: .normal)
            menuButton.backgroundColor = red
            
            menuCollection.isHidden = false
            imageCollection.isHidden = true
            
            imageButton.setTitleColor(gray, for: .normal)
            imageButton.backgroundColor = lightgray
            tap = "menu"
        }
    }
    
    func getImage() {
        db.collection("cafe_image").document(cafe_id).addSnapshotListener { documentSnapshot, err in
            guard let doc = documentSnapshot else {
                print("Error fetching document: \(err!)")
                return
            }
            let image = doc.get("cafe_image") as! [String]
            let menu = doc.get("cafe_menu") as! [String]
            self.imageArray = image.reversed()
            self.menuArray = menu.reversed()
            self.imageCollection.reloadData()
            self.menuCollection.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing == true {
            navigationItem.leftBarButtonItem = deleteBarButton
            deleteBarButton.isEnabled = false
        } else {
            setupBackButtonNavBar()
        }
        if imageButton.backgroundColor == red {
            imageCollection.allowsMultipleSelection = editing
            let indexPaths = imageCollection.indexPathsForVisibleItems
            for indexPath in indexPaths {
                let cell = imageCollection.cellForItem(at: indexPath) as! ImageCell
                cell.isInEditingMode = editing
            }
        }
        else {
            menuCollection.allowsMultipleSelection = editing
            let indexPaths = menuCollection.indexPathsForVisibleItems
            for indexPath in indexPaths {
                let cell = menuCollection.cellForItem(at: indexPath) as! ImageCell
                cell.isInEditingMode = editing
            }
            if editing == false {
                setupBackButtonNavBar()
            }
        }
    }
}

extension ImageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollection {
            return imageArray.count
        } else {
            return menuArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemPerRow: CGFloat = 3
        let interItemSpacing: CGFloat = 1
        if collectionView == imageCollection {
            let width = (imageCollection.frame.width - (numberOfItemPerRow * interItemSpacing)) / numberOfItemPerRow
            let height = width
            return CGSize(width: width, height: height)
        }
        else {
            let width = (menuCollection.frame.width - (numberOfItemPerRow * interItemSpacing)) / numberOfItemPerRow
            let height = width
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imageCollection {
            guard let cell = imageCollection.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
                return UICollectionViewCell()
            }
            cell.image.setImage(imageArray[indexPath.item])
            cell.isInEditingMode = isEditing
            return cell
        } else {
            guard let cell = menuCollection.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
                return UICollectionViewCell()
            }
            cell.image.setImage(menuArray[indexPath.item])
            cell.isInEditingMode = isEditing
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            setupBackButtonNavBar()
            let showImageVC = storyboard?.instantiateViewController(withIdentifier: "ShowImageVC") as! ShowImageViewController
            self.navigationController?.pushViewController(showImageVC, animated: true)
            if collectionView == imageCollection {
                showImageVC.items = imageArray
                showImageVC.indexPath = indexPath
            } else {
                showImageVC.items = menuArray
                showImageVC.indexPath = indexPath
            }
        } else {
            navigationItem.leftBarButtonItem = deleteBarButton
            deleteBarButton.isEnabled = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedItems = imageCollection.indexPathsForSelectedItems, selectedItems.count == 0 {
            navigationItem.leftBarButtonItem = deleteBarButton
            deleteBarButton.isEnabled = false
        }
    }
}
