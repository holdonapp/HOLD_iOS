//
//  Router.swift
//  Hold
//
//  Created by Admin on 11/27/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit

class Router {
    
    func initialWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = Router.rootNavigationController()
        
        return window
    }
    
    private static func rootNavigationController() -> UINavigationController? {
        let nav = UINavigationController()
        nav.viewControllers = [Router.rootViewController()]
        
        return nav
    }
    
    private static func rootViewController() -> RootViewController {
        let viewModel = RootViewModel(isFirstTimeUser: k_IsUsersFirstTime)
        let vc = RootViewController()
        vc.viewModel = viewModel
        
        return vc
    }
    
}

extension Router {
    
     static func loginViewController(viewModel: LoginViewModel) -> LoginViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
        vc.viewModel = viewModel
        
        return vc
    }
    
    static func authenticationViewController(viewModel: AuthenticationViewModel) -> AuthenticationViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Auth") as! AuthenticationViewController
        vc.viewModel = viewModel
        
        return vc
    }
    
    static func homeViewController(viewModel: HomeViewModel) -> HomeViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
        vc.viewModel = viewModel
        
        return vc
    }
    
}
