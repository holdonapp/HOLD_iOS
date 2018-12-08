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

extension UIImageView {
    
    func download(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill, completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: link) else { return }
        self.downloadFrom(url: url, contentMode: mode, completion: { complete in
            completion(complete)
        })
    }
    
    func downloadFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill, completion: @escaping (Bool) -> ()) {
        self.image = nil
        self.contentMode = mode
        
        URLSession.shared
            .dataTask(with: url) { [weak self] data, response, error in
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let this = self,
                    let data = data,
                    error == nil,
                    let image = UIImage(data: data)
                    else {
                        return DispatchQueue.main.async {
                            self?.alpha = 0
                            UIView.animate(withDuration: 0.2, animations: {
                                self?.layer.borderWidth = 1.0
                                self?.layer.borderColor = UIColor.lightGray.cgColor
                                self?.alpha = 1
                                
                                completion(true)
                            })
                        }
                }
                DispatchQueue.main.async() {
                    this.alpha = 0
                    UIView.animate(withDuration: 0.2, animations: {
                        this.image = image
                        this.alpha = 1
                        
                        completion(true)
                    })
                }
            }
            .resume()
    }
}
