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
    
    var viewModel: LoginViewModel? {
        didSet{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.push_AuthenticationViewController()
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
    }
}

extension LoginViewController {
    
    private func setup() {
        let colorTop = UIColor(displayP3Red: 255.0 / 255.0, green: 122.0 / 255.0, blue: 7.0 / 255.0, alpha: 0.2).cgColor
        let colorBottom = UIColor(displayP3Red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0).cgColor
        
        let gl = CAGradientLayer()
        gl.frame = self.view.bounds
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gl, at: 0)
        
        self.loginButtonOutlet.configureBordersWith(color: .holdOrange)
        self.signUpButtonOutlet.configureBordersWith(color: .holdOrange)
    }
    
    private func push_AuthenticationViewController() {
        guard let vc = self.viewModel?.persistAuthenticationViewController() else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor(red: 255.0 / 255.0, green: 122.0 / 255.0, blue: 7.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(displayP3Red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
