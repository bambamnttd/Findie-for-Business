//
//  TimeCell.swift
//  queueApp
//
//  Created by Bambam on 3/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class TimeCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.layer.cornerRadius = colorView.bounds.height / 2
        bgView.layer.cornerRadius = 15
        dayLabel.textColor = UIColor.init(red: 108/255, green: 108/255, blue: 108/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
