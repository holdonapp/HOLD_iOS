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
