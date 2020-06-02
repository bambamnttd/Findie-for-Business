//
//  ImageCell.swift
//  queueApp
//
//  Created by Bambam on 6/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var highlightIndicator: UIView!
    @IBOutlet weak var selectIndicator: UIImageView!
    
    var isInEditingMode: Bool = false {
        didSet {
            selectIndicator.isHidden = !isInEditingMode
            highlightIndicator.isHidden = !isInEditingMode
        }
    }

    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                selectIndicator.image = isSelected ? UIImage(named: "check") : UIImage()
                highlightIndicator.alpha = isSelected ? 0.3 : 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentMode = .topLeft
        highlightIndicator.isHidden = true
        selectIndicator.isHidden = true
    }

}
