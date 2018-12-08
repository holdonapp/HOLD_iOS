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
    
    func pullFirstFiftyImages(skip: Int, completion: @escaping ([HoldImageModel], Error?) -> ()) {
        let query = PFQuery(className: "TopLevelHashtags")
        query.limit = 50
        query.skip = skip
        query.findObjectsInBackground { (objects, error) in
            let canProceed = (error == nil && objects != nil) ? true : false
            switch canProceed {
            case true:
                guard let objects = objects else {return}
                completion(objects
                    .map({obj -> HoldImageModel in
                        let urlString = (obj["image"] as? PFFileObject)?.url ?? ""
                        let primaryHashTag = obj["hashtagId"] as? String ?? ""
                        let secondaryHashtag = obj["secondaryHashtagId"] as? String ?? ""
                        let postedByUserObjectID = obj["uploadedByUsername"] as? String ?? "Admin"
                        
                        return HoldImageModel.init(
                            urlString: urlString,
                            primaryHashTag: primaryHashTag,
                            secondaryHashtag: secondaryHashtag,
                            postedByUserObjectID: postedByUserObjectID
                        )
                    }), nil)
                
            case false:
                completion([], HoldError.apiError(error?.localizedDescription ?? "An error occured from the database"))
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
