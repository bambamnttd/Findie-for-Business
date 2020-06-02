//
//  UIImageView.swift
//  queueApp
//
//  Created by Bambam on 27/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

extension UIImageView {
    func setImage(_ imageURL: String) {
        let storageRef = Storage.storage().reference(forURL: imageURL)
        self.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "background.png"))
    }
}
