//
//  Extensions.swift
//  Hold
//
//  Created by Admin on 11/29/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    public static var holdOrange: UIColor {
        get {
            return UIColor(displayP3Red: 255/255, green: 122/255, blue: 7/255, alpha: 1)
        }
    }
    
}

extension UIButton {
    
    func configureBordersWith(color: UIColor) {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = 24
    }
    
    override open var isHighlighted: Bool {
        didSet {
            switch self.restorationIdentifier {
                
            case "login":
                self.backgroundColor = isHighlighted ? .holdOrange : .clear
                
            case "signUp":
                self.backgroundColor = isHighlighted ? .holdOrange : .clear
                
            case "auth_login":
                self.titleLabel?.textColor = isHighlighted ? .holdOrange : .white
                self.backgroundColor       = isHighlighted ? .white      : .holdOrange
                
            default:
                break
            }
        }
    }
    
}
