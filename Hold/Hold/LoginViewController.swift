//
//  LoginViewController.swift
//  Hold
//
//  Created by Miles Fishman on 6/28/20.
//  Copyright © 2020 Hold Inc. All rights reserved.
//

import Foundation
import UIKit
import Parse
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(message: "Cannot Have Empty Fields")
            return
        } else {
            login(username: emailTextField.text, password: passwordTextField.text)
        }
    }
}

//MARK: - Helpers
extension LoginViewController {
    
    func setup() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
}

// MARK: - TexField Delegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - API

extension LoginViewController {
    func login(username: String?, password: String?) {
        PFUser.logInWithUsername(
            inBackground: username ?? "",
            password: password ?? "",
            block: { [weak self] user, error in
                if let err = error {
                    self?.displayAlert(message: err.localizedDescription)
                } else {
                    if let _ = user {
                        DispatchQueue.main.async {
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            guard let vc = sb.instantiateViewController(withIdentifier: "slideshow") as? ViewController else { return }
                            vc.modalTransitionStyle = .crossDissolve
                            vc.modalPresentationStyle = .fullScreen
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
        })
    }
}
