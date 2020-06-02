//
//  UILabel.swift
//  queueApp
//
//  Created by Bambam on 28/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func setImageInLabel(text: String, image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: x, y: y, width: width, height: height)
        let attachmentString = NSAttributedString(attachment: attachment)
        let myString = NSMutableAttributedString(string: "")
        
        if text == "" {
            myString.append(attachmentString)
            self.attributedText = myString
        }
        else {
            let myString1 = NSMutableAttributedString(string: "  \(text)")
            myString.append(attachmentString)
            myString.append(myString1)
            self.attributedText = myString
        }
    }
}
