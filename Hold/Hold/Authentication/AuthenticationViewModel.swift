//
//  AuthenticationViewModel.swift
//  Hold
//
//  Created by Admin on 11/29/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import Parse

class AuthenticationViewModel {
    
    init() {
        
    }
    
}

extension AuthenticationViewModel {
    
    func login(_ username: String, password: String, completion: @escaping (PFUser?, Error?) -> ()) {
        let coordinator = Coordinator()
        coordinator.loginUserWith(username, password) { (user, error) in
            completion(user, error)
        }
    }
    
    func persistHomeViewController() -> HomeViewController {
        let viewModel = HomeViewModel()
        return Coordinator.homeViewController(viewModel: viewModel)
    }
}
