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
    var currentTag: String?
    var items = BehaviorRelay<[ImageObject]>(value: [])
    
    private var dismissingModal: Bool = false
    private var timer: Timer?
    private var loader: UIActivityIndicatorView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader = UIActivityIndicatorView(frame: .init(origin: view.center, size: .init(width: 100, height: 100)))
        loader.color = .orange
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
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        let tag = items.value[currentIndex].hashtagId
        vc.currentTag = tag
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
            ? (imageViewTwo.image = newImage) : imageViewTwo.alpha == 1
            ? (imageViewOne.image = newImage) : ()
        
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewTwo.alpha = self.imageViewTwo.alpha == 0 ? 1 : 0
            self.imageViewOne.alpha = self.imageViewOne.alpha == 0 ? 1 : 0
        })
    }
    
    func displayPhotos(at offsetIndex: Int = 0, onNext: Bool, isFirst: Bool = false) {
        // DispatchQueue.main.async {
        if let new = self.items.value[offsetIndex].localImage {
            guard !isFirst else {
                self.imageViewOne.image = UIImage(data: new)
                self.startTimer(); return
            }
            self.transitionImages(with: new)
        }
        //}
    }
    
    func updateIndex(onNext: Bool) {
        startTimer()
        
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
    
    func stopTimer() {
        if timer?.isValid == true {
            timer?.invalidate()
        }
        timer = nil
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            self.rightButtonPressed(self)
        })
    }
    
    func displayAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.dismiss(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    func bind() {
        view.addSubview(loader)
        loader.center = view.center
        loader.startAnimating()
        
        imageViewOne.backgroundColor = .clear
        imageViewTwo.backgroundColor = .clear
        imageViewTwo.alpha = 0
        
        pullImages(partitionkey: currentTag)
            .observeOn(MainScheduler.asyncInstance)
            .catchError({ [weak self] (error) -> Observable<[ImageObject]> in
                let errMesssage = ((error as? HoldError)?.localizedDescription ?? error.localizedDescription)
                self?.displayAlert(message: "ERROR:\n" + errMesssage + "\n\(self?.currentTag ?? "#")")
                return .just([])
            })
            .share()
            .bind(to: items)
            .disposed(by: disposeBag)
        
        items
            .observeOn(MainScheduler.instance)
            .skipWhile({ $0.isEmpty })
            .subscribe(onNext: { (objects) in
                objects.fetchImages({ [weak self] _ in
                    self?.loader.stopAnimating()
                    self?.displayPhotos(onNext: true, isFirst: true)
                })
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - HOLD API

extension ViewController {
    func pullImages(limit: Int = 20, skip: Int = .random(in: 0...2500), partitionkey: String? = nil) -> Observable<[ImageObject]> {
        var query = PFQuery(className: "TopLevelHashtags")
        if let key = partitionkey {
            query = PFQuery(className: "TopLevelHashtags", predicate: NSPredicate(format: "hashtagId = '\(key)'"))
        }
        query.limit = limit
        query.skip = skip
        
        return Observable.create { (o) -> Disposable in
            query.findObjectsInBackground { (objs, err) in
                switch err == nil {
                case true:
                    guard let objects = objs, !objects.isEmpty else {
                        o.onError(HoldError.emptyResponse)
                        o.onCompleted(); return
                    }
                    var results: [ImageObject] = []
                    var counterOne = results.count
                    
                    while counterOne < objects.count {
                        guard let object = ImageObject.create(from: objects[counterOne]) else {
                            o.onError(HoldError.parsing)
                            o.onCompleted(); return
                        }
                        results.append(object)
                        counterOne += 1
                        o.onNext(results)
                    }
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

// MARK: - Native Apple Extensions

extension Array where Element: ImageObject {
    func fetchImages(_ completion: @escaping ([Element]) -> Void) {
        DispatchQueue.global().async {
            self.forEach { (value) in
                value.localImage = try? value.image.getData()
            }
            DispatchQueue.main.async {
                completion(self)
            }
        }
    }
}

//MARK: - HOLD Errors

enum HoldError: Error {
    case parsing
    case emptyResponse
    case unAuthorized
    case database
    
    public var localizedDescription: String {
        switch self {
        case .parsing: return "Unable to parse the object model"
        case .emptyResponse: return "Empty response from API"
        case .unAuthorized: return "Unauthorized credentials"
        case .database: return "API database error"
        }
    }
}
