//
//  FacilityCell.swift
//  queueApp
//
//  Created by Bambam on 7/5/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit

protocol SelectedDelegate: class {
    func selected(topic: String, bool: Bool)
}


class FacilityCell: UITableViewCell {
    
    @IBOutlet weak var facilityLabel: UILabel!
    @IBOutlet weak var yesImage: UIImageView!
    @IBOutlet weak var noImage: UIImageView!
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    
    var delegate: SelectedDelegate?
    var data : FacilityData!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImageTap()
    }
    
    func setImageTap() {
        let imageTap1 = UITapGestureRecognizer(target: self, action: #selector(tapyes))
        yesImage.isUserInteractionEnabled = true
        yesImage.addGestureRecognizer(imageTap1)
        
        let imageTap2 = UITapGestureRecognizer(target: self, action: #selector(tapno))
        noImage.isUserInteractionEnabled = true
        noImage.addGestureRecognizer(imageTap2)
    }
    
    @objc func tapyes() {
        if yesImage.image == UIImage(named: "uncheck.png") {
            yesImage.image = UIImage(named: "check.png")
            noImage.image = UIImage(named: "uncheck.png")
            delegate?.selected(topic: data.topic, bool: true)
        }
    }
    
    @objc func tapno() {
        if noImage.image == UIImage(named: "uncheck.png") {
            noImage.image = UIImage(named: "check.png")
            yesImage.image = UIImage(named: "uncheck.png")
            delegate?.selected(topic: data.topic, bool: false)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
