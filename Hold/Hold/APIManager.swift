//
//  APIManager.swift
//  Hold
//
//  Created by Admin on 11/27/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import Parse

class APIManager {
    
    init() {
        
    }
    
}

extension APIManager {
    
    func login(username: String, password: String, completion: @escaping (PFUser?, Error?) -> ()) {
        PFUser.logInWithUsername(inBackground: username, password: password
        ) { user, error in
            
            print("Hit")
            
            let canProceed = (error == nil && user != nil) ? true : false
            switch canProceed {
            case true:
                guard let user = user else {
                    return completion(nil, HoldError.apiError(error?.localizedDescription ?? "An error occured from the database"))
                }
                completion(user, nil)
                
            case false:
                completion(nil, HoldError.apiError(error?.localizedDescription ?? "An error occured from the database"))
            }
        }
    }
}

enum HoldError: Error {
    case apiError(_ description: String)
    
    var message: String {
        switch self {
        case .apiError(let description):
            return description
        }
    }
}
