//
//  InfoListCell.swift
//  queueApp
//
//  Created by Bambam on 30/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class InfoListCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var topicLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        barView.layer.cornerRadius = barView.bounds.height / 2
        barView.layer.borderColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
        barView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
