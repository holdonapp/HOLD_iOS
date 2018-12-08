//
//  Coordinator.swift
//  Hold
//
//  Created by Admin on 11/27/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Coordinator {
    
    static let shared: Coordinator = Coordinator()
    
    private init(){}
    
    static func presentRootWindow() -> UIWindow {
        let router = Router()
        return router.initialWindow()
    }
    
    static func onBoardingViewController() -> UIViewController? {
        return nil
    }
    
    static func loginViewController(viewModel: LoginViewModel) -> LoginViewController {
        return Router.loginViewController(viewModel: viewModel)
    }
    
    static func authenticationViewController(viewModel: AuthenticationViewModel) -> AuthenticationViewController {
        return Router.authenticationViewController(viewModel: viewModel)
    }
    
    static func homeViewController(viewModel: HomeViewModel) -> HomeViewController {
        return Router.homeViewController(viewModel: viewModel)
    }
 
}


extension Coordinator {
    
    func loginUserWith(_ username: String, _ password: String, completion: @escaping (PFUser?, Error?) -> ()) {
        let api = APIManager()
        api.login(username: username, password: password) { (user, error) in
            completion(user, error)
        }
    }
    
    func pullFirstFiftyImages(skip: Int, completion: @escaping ([HoldImageModel], Error?) -> ()) {
        let api = APIManager()
        api.pullFirstFiftyImages(skip: skip) { (imageModels, error) in
            completion(imageModels, error)
        }
    }

}

// Temporary shared vars will transfer to Userdefaults
extension Coordinator {
    
    
    
    
}
