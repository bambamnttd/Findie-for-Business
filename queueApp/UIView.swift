//
//  UIView.swift
//  queueApp
//
//  Created by Bambam on 30/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setShadow() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
    }
}
