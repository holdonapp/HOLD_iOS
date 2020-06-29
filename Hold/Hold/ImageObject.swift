//
//  ImageObject.swift
//  Hold
//
//  Created by Miles Fishman on 6/26/20.
//  Copyright © 2020 Hold Inc. All rights reserved.
//

import Foundation
import Parse

// MARK: - Model

class ImageObject {
    var objectId: String = ""
    var description: String?
    var hashtagId: String = ""
    var secondaryHashtagId: String = ""
    var uploadedByUsername: String?
    
    /// Image File Object
    var image: PFFileObject
    
    /// Client Side Initialization Only
    var localImage: Data?
    
    init(
        objectId: String,
        description: String?,
        hashtagId: String,
        secondaryHashtagId: String,
        uploadedByUsername: String?,
        image: PFFileObject
    ) {
        self.objectId = objectId
        self.description = description
        self.hashtagId = hashtagId
        self.secondaryHashtagId = secondaryHashtagId
        self.uploadedByUsername = uploadedByUsername
        self.image = image
    }
    
    static func create(from pfObject: PFObject) -> ImageObject? {
        guard
            let objectId = pfObject.objectId,
            let hashtagId = pfObject["hashtagId"] as? String,
            let secondaryHashtagId = pfObject["secondaryHashtagId"] as? String,
            let image = pfObject["image"] as? PFFileObject
            else {
                return  nil
        }
        let description = pfObject["description"] as? String
        let uploadedByUsername = pfObject["uploadedByUsername"] as? String
        
        return ImageObject(
            objectId: objectId,
            description: description,
            hashtagId: hashtagId,
            secondaryHashtagId: secondaryHashtagId,
            uploadedByUsername: uploadedByUsername,
            image: image
        )
    }
}
