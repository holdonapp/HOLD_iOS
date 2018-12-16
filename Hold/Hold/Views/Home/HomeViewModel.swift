//
//  HomeViewModel.swift
//  Hold
//
//  Created by Admin on 11/29/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit

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
    
    func convert(_ models: [HoldImageModel]) -> [PresentableModel] {
        typealias UrlWithId = (URL?, String)
        
        let nonNils = models.filter({$0.imageUrlString != nil})
        guard !nonNils.isEmpty else {return []}
        
        let urlArray = nonNils
            .map({ (model) -> UrlWithId? in
                return UrlWithId(URL(string: model.imageUrlString ?? "Invalid URL String") ?? nil, model.id)
            })
            .filter({ $0?.0 != nil && $0?.0?.absoluteString != "Invalid URL String" })
        
        guard !urlArray.isEmpty else {return []}
        
        let dataArray = urlArray
            .map({ return $0! })
            .map { (model) -> PresentableModel in
                let result = PresentableModel.init(data: try! Data(contentsOf: model.0!), id: model.1)
                return result
        }
        
        return dataArray
    }
    
//    func new(from displayModel: [ImageDisplay], and imageModels: [HoldImageModel]) -> [ImageDisplay] {
//        return imageModels
//            .filter({
//                $0.primaryHashTag ==
//            })
//            .map({ (display) -> ImageDisplay in
//            
//        })
//        
//    }
    
}
