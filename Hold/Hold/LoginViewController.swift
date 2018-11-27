//
//  LoginViewController.swift
//  Hold
//
//  Created by Admin on 11/14/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
    }
}

extension LoginViewController {
    
    func setup() {
        let orange = UIColor.hold_Orange()
        self.loginButtonOutlet.configureBordersWith(color: orange)
        self.signUpButtonOutlet.configureBordersWith(color: orange)
    }
    
}

extension UIColor {
    
    static func hold_Orange() -> UIColor {
        return UIColor(displayP3Red: 255/255, green: 122/255, blue: 7/255, alpha: 1)
    }

}

extension UIButton {
    
    func configureBordersWith(color: UIColor) {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = 24
    }
}
