//  ViewController.swift
//  Hold
//
//  Created by Miles Fishman on 11/14/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
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
    
    func fetchImageData(_ completion: @escaping (Data) -> Void) {
        image.getDataInBackground { [weak self] (data, error) in
            guard let data = data else { return }
            self?.localImage = data
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

// MARK: - Lifecycle

class ViewController: UIViewController {
    
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    
    var currentIndex: Int = 0
    var currentTag: String = "TopLevelHashtags"
    var items = BehaviorRelay<[ImageObject]>(value: [])
    
    private var dismissingModal: Bool = false
    private var timer: Timer?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !dismissingModal else {
            startTimer(); return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissingModal = true
    }
    
    @IBAction func topButtonPressed(_ sender: Any) {
        stopTimer()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "slideshow") as? ViewController else { return }
        present(vc, animated: true)
    }
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        guard presentingViewController == nil else {
            stopTimer()
            dismiss(animated: true); return
        }
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        updateIndex(onNext: false)
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        updateIndex(onNext: true)
    }
}

// MARK: - Private Helpers

private extension ViewController {
    func transitionImages(with newData: Data) {
        let newImage = UIImage(data: newData)
        self.imageViewOne.alpha == 1
            ? (self.imageViewTwo.image = newImage) : self.imageViewTwo.alpha == 1
            ? (self.imageViewOne.image = newImage) : ()
        
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewTwo.alpha = self.imageViewTwo.alpha == 0 ? 1 : 0
            self.imageViewOne.alpha = self.imageViewOne.alpha == 0 ? 1 : 0
        })
    }
    
    func displayPhotos(at offsetIndex: Int = 0, onNext: Bool, isFirst: Bool = false) {
        if let new = items.value[offsetIndex].localImage {
            guard !isFirst else {
                self.imageViewOne.image = UIImage(data: new); return
            }
            self.transitionImages(with: new)
        }
    }
    
    func updateIndex(onNext: Bool) {
        let lastItem: Int = items.value.count - 1,
        firstItem: Int = 0
        let pressedBackOnFirstItem: Bool = !onNext && currentIndex == firstItem,
        pressedNextOnLastItem: Bool = onNext && currentIndex == lastItem
        
        if pressedNextOnLastItem {
            currentIndex = 0
        } else if pressedBackOnFirstItem {
            currentIndex = lastItem
        } else {
            onNext ? (currentIndex += 1) : (currentIndex -= 1)
        }
        displayPhotos(at: currentIndex, onNext: onNext)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            self.rightButtonPressed(self)
        })
        timer?.fire()
    }
    
    func stopTimer() {
        if timer?.isValid == true {
            timer?.invalidate()
        }
        timer = nil
    }
    
    func bind() {
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
                    obs.fetchImages({ [weak self] _ in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.displayPhotos(onNext: true, isFirst: true)
                            self.startTimer()
                        }
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
}

// MARK: - API

extension ViewController {
    func pullImages(limit: Int = 20, skip: Int = 0) -> Observable<[ImageObject]> {
        let query = PFQuery(className: currentTag)
        query.limit = limit
        query.skip = skip
        
        return Observable.create { (o) -> Disposable in
            query.findObjectsInBackground { (objs, err) in
                switch err == nil {
                case true:
                    guard let objects = objs, !objects.isEmpty else {
                        o.onError(NSError())
                        o.onCompleted(); return
                    }
                    var results: [ImageObject] = []
                    var counterOne = results.count
                    
                    while counterOne < objects.count {
                        guard let object = ImageObject
                            .create(from: objects[counterOne]) else {
                                o.onError(NSError())
                                o.onCompleted(); return
                        }
                        results.append(object)
                        counterOne += 1
                    }
                    o.onNext(results)
                    o.onCompleted()
                    
                case false:
                    o.onError(err!)
                    o.onCompleted()
                }
            }
            return Disposables.create {}
        }
    }
}

// MARK: - Extensions

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
