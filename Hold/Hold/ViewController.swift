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
        showLoader()
        setupImageViews()
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
        let count = items.value.count
        guard offsetIndex != count else {
            items.accept([])
            showLoader()
            currentIndex = 0
            bind()
            return
        }
        if let new = self.items.value[offsetIndex].localImage {
            guard !isFirst else {
                self.imageViewOne.image = UIImage(data: new)
                self.startTimer(); return
            }
            self.transitionImages(with: new)
        }
    }
    
    func updateIndex(onNext: Bool) {
        startTimer()
        
        let lastItem: Int = items.value.count - 1,
        firstItem: Int = 0
        let pressedBackOnFirstItem: Bool = !onNext && currentIndex == firstItem,
        pressedNextOnLastItem: Bool = onNext && currentIndex == lastItem
        if pressedNextOnLastItem {
            currentIndex += 1
        } else if pressedBackOnFirstItem {
            currentIndex += 0
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
    
    func showLoader() {
        loader = UIActivityIndicatorView(frame: .init(origin: view.center, size: .init(width: 200, height: 200)))
        loader.color = .black
        view.addSubview(loader)
        loader.center = view.center
        loader.startAnimating()
    }
    
    func setupImageViews() {
        imageViewOne.backgroundColor = .clear
        imageViewTwo.backgroundColor = .clear
        imageViewTwo.alpha = 0
    }
    
    func bind() {
        pullImages(partitionkey: currentTag)
            .observeOn(MainScheduler.asyncInstance)
            .retry(10) // <-- Arbitrary number just incase random index lands after a set of hashtags that DO exist.
            .catchError({ [weak self] (error) -> Observable<[ImageObject]> in
                let errMesssage = ((error as? HoldError)?.localizedDescription ?? error.localizedDescription)
                self?.displayAlert(message: "ERROR:\n" + errMesssage + "\n\(self?.currentTag ?? "#")")
                return .just([])
            })
            .share()
            .bind(to: items)
            .disposed(by: disposeBag)
        
        items
            .skipWhile({ $0.isEmpty })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                $0.fetchImages(controllerInCaseOfError: self, { [weak self] _, error in
                    if let err = error {
                        self?.displayAlert(message: err.localizedDescription)
                    } else {
                        self?.displayPhotos(onNext: true, isFirst: true)
                    }
                    self?.loader.removeFromSuperview()
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
                        return
                    }
                    var results: [ImageObject] = []
                    var counterOne = results.count
                    while counterOne < objects.count {
                        guard let object = ImageObject.create(from: objects[counterOne]) else {
                            o.onError(HoldError.parsing)
                            return
                        }
                        results.append(object)
                        counterOne += 1
                        o.onNext(results)
                    }
                    o.onCompleted()
                    
                case false:
                    o.onError(err!)
                }
            }
            return Disposables.create {}
        }
    }
}

