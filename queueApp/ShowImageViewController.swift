//
//  ShowMenuViewController.swift
//  thesisApp
//
//  Created by Bambam on 22/2/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import FirebaseUI

class ShowImageViewController: UIViewController {
    
    @IBOutlet weak var menuImageCollectionView: UICollectionView!
    
    var menuImageView: UIImageView!
    var scrollView: UIScrollView!
    var indexPath: IndexPath!
    var items: [String]!
    var cafename_en = String()
    let countCells = 1
    let cellIdentifier = "ShowImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupScrollView()
        setCollectionView()
//        setImageView()
        setupBackButtonNavBar()
        navigationItem.title = cafename_en
    }
    
    func setCollectionView() {
        menuImageCollectionView.backgroundColor = .white
        menuImageCollectionView.delegate = self
        menuImageCollectionView.dataSource = self
        menuImageCollectionView.register(UINib(nibName: "ShowImageCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        menuImageCollectionView.performBatchUpdates(nil) { (result) in
            self.menuImageCollectionView.scrollToItem(at: self.indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

extension ShowImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameCV = view.frame
        let widthCell = frameCV.width / CGFloat(countCells)
        let heightCell = frameCV.height / CGFloat(countCells)
        return CGSize(width: widthCell, height: heightCell)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = menuImageCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ShowImageCell
        cell.fullMenuImage.setImage(items[indexPath.item])
        return cell
    }

}
