//
//  RewardCell.swift
//  queueApp
//
//  Created by Bambam on 4/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class RewardCell: UITableViewCell {
    
    @IBOutlet weak var rewardImage: UIImageView!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
