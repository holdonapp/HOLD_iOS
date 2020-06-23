//
//  ViewController.swift
//  Hold
//
//  Created by Admin on 11/14/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Parse

class ImageObject {
    var objectId: String = ""
    var description: String?
    var hashtagId: String = ""
    var secondaryHashtagId: String = ""
    var uploadedByUsername: String?
    
    /// Image Object
    var image: PFFileObject
    
    /// Local Initialization Only
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
    
    func fetchImageData(_ completion: @escaping (Data) -> Void) {
        image.getDataInBackground { [weak self] (data, error) in
            guard let data = data else {
                return
            }
            self?.localImage = data
            print("didIt")
            completion(data)
        }
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

class ViewController: UIViewController {
    
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    
    typealias ImagePair = (img1: UIImage, img2: UIImage)
    
    var position: Int = 0
    var managedHashtags: [String] = []
    var items = BehaviorRelay<[ImageObject]>(value: [])
    var currentIndex: Int = 0
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageViewOne.backgroundColor = .clear
        imageViewTwo.backgroundColor = .clear
        imageViewTwo.alpha = 0
        
        pullImages()
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .bind(to: items)
            .disposed(by: disposeBag)
        
        items
            .asObservable()
            .skip(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(
                onNext: { (objects) in
                    let obs = objects
                    obs.fetchImages({ [weak self] (values) in
                        guard let self = self else { return }
                        print(values.map({ $0.localImage }))
                        self.displayPhotos(onNext: true, isFirst: true)
                    })
            },
                onError: { (error) in
                    print("error")
            },
                onCompleted: {
                    print("Finished Loading Images")
            })
            .disposed(by: disposeBag)
    }
    
    func transitionImages(with newData: Data) {
        let newImage = UIImage(data: newData)
        
        if imageViewOne.alpha == 1 {
            imageViewTwo.image = newImage
        } else if imageViewTwo.alpha == 1 {
            imageViewOne.image = newImage
        }
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewOne.alpha = self.imageViewOne.alpha == 0 ? 1 : 0
        })
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewTwo.alpha = self.imageViewTwo.alpha == 0 ? 1 : 0
        })
        print(currentIndex)
    }
    
    func displayPhotos(at offsetIndex: Int = 0, onNext: Bool, isFirst: Bool = false) {
        let photos = items.value
        guard let new = photos[offsetIndex].localImage else { return }
        
        guard !isFirst else {
            imageViewOne.image = UIImage(data: new)
            return
        }
        DispatchQueue.main.async {
            self.transitionImages(with: new)
        }
    }
    
    func updateIndex(onNext: Bool) {
        let lastItem = items.value.count - 1
        let firstItem = 0
        let pressedNextOnLastItem = onNext && currentIndex == lastItem
        let pressedBackOnFirstItem = !onNext && currentIndex == firstItem
        if pressedNextOnLastItem {
            currentIndex = 0
        } else if pressedBackOnFirstItem {
            currentIndex = lastItem
        } else {
            onNext ? (currentIndex += 1) : (currentIndex -= 1)
        }
        displayPhotos(at: currentIndex, onNext: onNext)
    }
    
    @IBAction func topButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        updateIndex(onNext: false)
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        updateIndex(onNext: true)
    }
}

// API
extension ViewController {
    func pullImages(limit: Int = 20, skip: Int = 0) -> Observable<[ImageObject]> {
        let query = PFQuery(className: "TopLevelHashtags")
        query.limit = limit
        query.skip = skip
        
        return Observable.create { (o) -> Disposable in
            query.findObjectsInBackground { (objs, err) in
                switch err == nil {
                case true:
                    guard let objects = objs, !objects.isEmpty else {
                        o.onError(NSError()); o.onCompleted()
                        return
                    }
                    var results: [ImageObject] = []
                    var counterOne = results.count
                    
                    while counterOne < objects.count {
                        guard let object = ImageObject.create(from: objects[counterOne]) else {
                            o.onError(NSError()); o.onCompleted()
                            return
                        }
                        results.append(object)
                        counterOne += 1
                    }
                    o.onNext(results); o.onCompleted()
                    
                case false:
                    o.onError(err!); o.onCompleted()
                }
            }
            return Disposables.create {}
        }
    }
}

extension Array where Element: ImageObject {
    
    func fetchImages(_ completion: @escaping ([Element]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.forEach { (value) in
                value.localImage = try? value.image.getData()
                print("\(value.objectId)")
            }
            DispatchQueue.main.async {
                completion(self)
            }
        }
    }
}
