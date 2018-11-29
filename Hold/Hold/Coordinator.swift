//
//  Coordinator.swift
//  Hold
//
//  Created by Admin on 11/27/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit

class Coordinator {
    
    static func presentRootWindow() -> UIWindow {
        let router = Router()
        return router.initialWindow()
    }
    
    static func onBoardingViewController() -> UIViewController? {
        
        
        return nil
    }
    
    static func authenticationViewController() -> UIViewController? {
        
        
        return nil
    }
}
