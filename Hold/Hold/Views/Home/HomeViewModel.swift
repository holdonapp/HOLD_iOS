//
//  HomeViewModel.swift
//  Hold
//
//  Created by Admin on 11/29/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation

class HomeViewModel {
    var user: UserModel
    
    init(user: UserModel) {
        self.user = user
    }
    
}

extension HomeViewModel {
    func pullFirstFiftyImages(skip: Int, completion: @escaping ([HoldImageModel], Error?) -> ()) {
        let coo = Coordinator.shared
        coo.pullFirstFiftyImages(skip: skip) { (imageModels, error) in
            completion(imageModels, error)
        }
    }
}
