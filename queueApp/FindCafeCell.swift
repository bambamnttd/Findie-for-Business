//
//  FindCafeCell.swift
//  queueApp
//
//  Created by Bambam on 27/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

class FindCafeCell: UITableViewCell {
    
    @IBOutlet weak var cafenameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cafeImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cafeImage.layer.cornerRadius = 5
        bgView.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = UIColor.init(red: 90/255, green: 100/255, blue: 50/255, alpha: 1).cgColor
        }
        else {
            bgView.layer.borderWidth = 0
        }
    }

}
