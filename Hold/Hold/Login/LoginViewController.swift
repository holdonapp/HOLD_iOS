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
        self.loginButtonOutlet.configureBordersWith(color: .holdOrange)
        self.signUpButtonOutlet.configureBordersWith(color: .holdOrange)
    }
    
    private func push_AuthenticationViewController() {
        guard let vc = self.viewModel?.persistAuthenticationViewController() else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
