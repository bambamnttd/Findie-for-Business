//
//  TypeCafeCell.swift
//  queueApp
//
//  Created by Bambam on 28/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class TypeCafeCell: UITableViewCell {
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        checkImage.image = UIImage(named: "uncheck.png")
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        if selected {
//            checkImage.image = UIImage(named: "check.png")
//        }
//        else {
//            checkImage.image = UIImage(named: "uncheck.png")
//        }
//    }

}
