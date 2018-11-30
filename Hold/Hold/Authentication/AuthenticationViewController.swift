//
//  AuthenticationViewController.swift
//  Hold
//
//  Created by Admin on 11/29/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit

class AuthenticationViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    @IBOutlet weak var forgotPasswordButtonOutlet: UIButton!
    
    var viewModel: AuthenticationViewModel? {
        didSet{
            guard let _ = viewModel else {return}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.setupTextViews()
        self.setupButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cleanUp()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let overlay = self.createLoaderView()
        self.view.addSubview(overlay)
        
        guard let username = self.usernameTextField.text, let password = self.passwordTextField.text else {return}
        self.viewModel?
            .login(username, password: password, completion: { [weak self] (user, error) in
                DispatchQueue.main.async {
                    overlay.removeFromSuperview()
                    
                    switch error == nil {
                    case true:
                        guard let vc = self?.viewModel?.persistHomeViewController() else {return}
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    case false:
                        guard let err = error as? HoldError else {return}
                        self?.show(err)
                    }
                }
            })
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        // TO-DO
    }
}

extension AuthenticationViewController {
    
    private func setupNavBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .lightGray
        self.navigationController?.view.backgroundColor = .clear
        
        let logo = #imageLiteral(resourceName: "contentSelectorPurple")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        self.navigationItem.titleView = v
    }
    
    fileprivate func setupTextViews() {
        self.usernameTextField.borderStyle = UITextField.BorderStyle.none
        self.passwordTextField.borderStyle = UITextField.BorderStyle.none
        self.addBottomBorderToTextField(myTextField: self.usernameTextField)
        self.addBottomBorderToTextField(myTextField: self.passwordTextField)
    }
    
    private func setupButtons() {
        self.loginButtonOutlet.layer.cornerRadius = 16
        self.loginButtonOutlet.backgroundColor = .holdOrange
    }
    
    fileprivate func addBottomBorderToTextField(myTextField:UITextField) {
        let bottomLine   = CALayer()
        bottomLine.frame = CGRect(x:0.0,y: myTextField.frame.height - 1,
                                  width  : self.view.frame.width - 40,
                                  height : 0.5)
        
        bottomLine.backgroundColor = UIColor.holdOrange.cgColor
        bottomLine.opacity = 0.6
        myTextField.borderStyle = UITextField.BorderStyle.none
        myTextField.layer.addSublayer(bottomLine)
    }
    
    private func createLoaderView() -> UIView {
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = .black
        overlay.alpha = 0.6
        
        let act = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        act.style = .whiteLarge
        act.color = .holdOrange
        act.center = overlay.center
        act.startAnimating()
        overlay.addSubview(act)
        
        return overlay
    }
    
    private func cleanUp() {
        self.usernameTextField.text?.removeAll()
        self.passwordTextField.text?.removeAll()
    }
    
    private func show(_ error: HoldError) {
        let alert = UIAlertController(title: "Something Went Wrong", message: error.message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Got It", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        print("Error - \(error.message)")
    }
}
