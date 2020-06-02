//
//  DayCell.swift
//  queueApp
//
//  Created by Bambam on 2/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class DayCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayView.layer.cornerRadius = dayView.bounds.height / 2
        dayLabel.textColor = UIColor.init(red: 138/255, green: 138/255, blue: 142/255, alpha: 1)
        dayView.backgroundColor = .white
    }
}
