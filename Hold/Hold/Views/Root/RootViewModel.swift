//
//  RootViewModel.swift
//  Hold
//
//  Created by Admin on 11/28/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation

class RootViewModel {
    
    var isFirstTimeUser: Bool = true
    
    init(isFirstTimeUser: Bool) {
        self.isFirstTimeUser = isFirstTimeUser
    }
}

extension RootViewModel {
    
    func persistLoginViewController() -> LoginViewController {
        let viewModel = LoginViewModel()
        return Coordinator.loginViewController(viewModel: viewModel)
    }
}
