//
//  LoginViewModel.swift
//  Hold
//
//  Created by Admin on 11/27/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    init() {
        
    }
}

extension LoginViewModel {
    
    func persistAuthenticationViewController() -> AuthenticationViewController {
        let viewModel = AuthenticationViewModel()
        return Coordinator.authenticationViewController(viewModel: viewModel)
    }
}
