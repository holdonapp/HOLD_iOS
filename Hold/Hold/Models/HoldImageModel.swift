//
//  HoldImageModel.swift
//  Hold
//
//  Created by Admin on 12/6/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit

struct HoldImageModel {
    var id: String
    var image: UIImage?
    var imageUrlString: String?
    var primaryHashTag: String
    var secondaryHashtag: String
    let description: String
    var postedByUserObjectID: String
}
