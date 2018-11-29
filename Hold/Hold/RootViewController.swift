//
//  RootViewController.swift
//  Hold
//
//  Created by Admin on 11/28/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit



class RootViewController: UIViewController {
    
    var isFirstTimeUse: Bool = true
    
    var viewModel: RootViewModel? {
        didSet {
            guard let vm = viewModel else {return}
            self.isFirstTimeUse = vm.isFirstTimeUser
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.isFirstTimeUse {
        case true:
            self.push_OnBoardingViewController()
            
        case false:
            self.push_LoginViewController()
        }
    }
}

extension RootViewController {
    
    private func push_LoginViewController() {
        
    }
    
    private func push_OnBoardingViewController() {
        
    }
    
}
