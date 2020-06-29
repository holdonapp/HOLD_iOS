//
//  Extensions.swift
//  Hold
//
//  Created by Miles Fishman on 6/27/20.
//  Copyright © 2020 Hold Inc. All rights reserved.
//

import Foundation
import UIKit

//MARK: - HOLD Error Cases

enum HoldError: Error {
    case parsing
    case emptyResponse
    case unAuthorized
    case message(text: String)
    
    public var localizedDescription: String {
        switch self {
        case .parsing: return "Unable to parse the object model"
        case .emptyResponse: return "Empty response from API"
        case .unAuthorized: return "Unauthorized credentials"
        case .message(let text): return text
        }
    }
}

// MARK: - Native Extensions

// UIViewController
extension UIViewController {
    func displayAlert(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { (_) in
                self?.dismiss(animated: true)
            }
            alert.addAction(action)
            self?.present(alert, animated: true)
        }
    }
}

// Array
extension Array where Element: ImageObject {
    func fetchImages(controllerInCaseOfError: UIViewController?, _ completion: @escaping ([Element], HoldError?) -> Void) {
        self.forEach { (value) in
            value.image.getDataInBackground { (data, error) in
                DispatchQueue.main.async {
                    if let err = error {
                        completion([], HoldError.message(text: err.localizedDescription))
                    } else if let data = data {
                        value.localImage = data
                        completion(self, nil)
                    }
                }
            }
        }
    }
}
