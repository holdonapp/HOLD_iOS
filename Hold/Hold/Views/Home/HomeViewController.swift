//
//  HomeViewController.swift
//  Hold
//
//  Created by Admin on 11/28/18.
//  Copyright © 2018 Hold Inc. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import RxCocoa
import RxSwift

typealias ImageDisplay = (description: String, image: UIImage?, id: String)

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    
    @IBOutlet weak var imageDetailsView: UIView!
    @IBOutlet weak var imageDetailUserProfileImageView: UIImageView!
    @IBOutlet weak var imageDetailUsernameLabel: UILabel!
    @IBOutlet weak var imageDetailDescriptionLabel: UILabel!
    @IBOutlet weak var imageDetailPrimaryHashtagLabel: UILabel!
    @IBOutlet weak var imageDetailViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageDetailViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageDetailViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageDetailBlurBackgroundFxView: UIVisualEffectView!
    
    private var currentId: String?
    private var currentIndex:Int = 0
    private var cancel: Bool = false
    
    private let minImageBagCount: Int = 20
    private var skipCount: Int = 0
    
    private let collapsedHeightConstant: CGFloat = 50
    private let collapsedEdgeConstraintConstant: CGFloat = 45
    private let openHeightConstant: CGFloat = 120
    private let openEdgeConstraintConstant: CGFloat = 10
    
    private var imageDetailTimer: Timer?
    private var imageTransitionTimer: Timer?
    private var imagePrefetchTimer: Timer?
    private var imageDetailVanishTimer: Timer?
    
    private var currentImageBag: [HoldImageModel] = []
    private var primaryImageBag: [HoldImageModel] = []
    private var imageModelbag: [ImageDisplay] = []
    
    private var currentImage: UIImageView!
    private var upcomingImage: UIImageView!
    
    private var startingPoint: CGAffineTransform!
    
    private var shouldChangeImage: Bool = false
    private var detailsAreOpen: Bool = false
    
    var viewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.pullImages(skip: self.skipCount)
        self.addGestureToDetails()
        self.addGestureToView()
        self.swipeGestureView()
        self.layoutBarButtons()
    }
    
    deinit {
        print("Deinit success - \(self.description)")
    }
    
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        if self.currentIndex != 0 {
            self.currentIndex -= 1
            var bag = self.primaryImageBag
            
            let element = bag.remove(at: self.currentIndex)
            self.currentImageBag.insert(element, at: 0)
            self.processNew(images: self.currentImageBag, inTransition: true)
        }
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        self.currentIndex += 1
        var bag = self.primaryImageBag
        
        let element = bag.remove(at: self.currentIndex)
        self.currentImageBag.removeFirst()
        self.currentImageBag.insert(element, at: 0)
        self.processNew(images: self.currentImageBag, inTransition: true)
    }
}

extension HomeViewController {
    
    private func setup() {
        self.startingPoint = CGAffineTransform(translationX: -10, y: 10).concatenating(CGAffineTransform(scaleX: 1.3, y: 1.3))
        
        self.upcomingImage = UIImageView(frame: self.mediaImageView.bounds)
        self.upcomingImage.contentMode = .scaleAspectFill
        self.upcomingImage.alpha = 0
        self.upcomingImage.transform = self.startingPoint
        self.upcomingImage.clipsToBounds = true
        
        self.currentImage = UIImageView(frame: self.mediaImageView.bounds)
        self.currentImage.contentMode = .scaleAspectFill
        self.currentImage.alpha = 0
        self.currentImage.transform = self.startingPoint
        self.currentImage.clipsToBounds = true
        
        self.imageDetailsView.alpha = 0
        self.imageDetailsView.layer.cornerRadius = 25
        
        self.imageDetailBlurBackgroundFxView.layer.cornerRadius = 25
        
        self.imageDetailUserProfileImageView.layer.cornerRadius = self.imageDetailUserProfileImageView.bounds.width / 2
    }
    
    private func pullImages(skip: Int){
        let data = self.createLoaderViewData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
        
        self.currentImageBag.removeAll()
        self.imageModelbag.removeAll()
        
        self.viewModel?.pullFirstFiftyImages(skip: skip, completion: { (models, error) in
            let canProceed = (error == nil && !models.isEmpty) ? true : false
            switch canProceed {
            case true:
                self.beginImageCycling(with: models)
                
            case false:
                break
            }
        })
    }
    
    private func layoutBarButtons() {
        let right = UIBarButtonItem(image: #imageLiteral(resourceName: "contentSelectorPurple"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.openRightMenu))
        self.navigationItem.rightBarButtonItems = [right]
    }
    
    private func createLoaderViewData() -> ActivityData {
        let data = ActivityData(
            size     : CGSize(width: 50, height: 50),
            message  : "",
            type     : .circleStrokeSpin,
            color    : .holdOrange,
            textColor: .white
        )
        return data
    }
    
    private func beginImageCycling(with bag: [HoldImageModel]) {
        guard let dataArray = self.viewModel?.convert(bag), !dataArray.isEmpty else {return}
        
        let images = dataArray.isEmpty ? [] : dataArray
            .map({ (data) -> PresentingImageModel? in
                let result = PresentingImageModel.init(image: UIImage(data: data.data)!, id: data.id)
                return result
            })
            .filter({ $0 != nil })
            .map({ return $0! })
        
        let newModels = bag.map { (model) -> HoldImageModel in
            var m = model
            m.image = images.filter({$0.id == model.id}).first?.image
            return m
        }
        
        self.imageModelbag = newModels
            .map({ img -> ImageDisplay in
                let desc = img.description == "" ? img.primaryHashTag : img.description
                let details = ImageDisplay(desc, #imageLiteral(resourceName: "person-placeholder"), img.id)
                return details
            })
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        
        switch images.isEmpty {
        case true:
            print("Alert - No images to show at this time")
            
        case false:
            self.primaryImageBag = newModels
            
            self.processNew(
                images: newModels, inTransition: false)
        }
    }
    
    private func processNew(images: [HoldImageModel], inTransition: Bool) {
        DispatchQueue.main.async {
            self.startImageDetailTimer()
            self.startImageDetailVanishTimer()
            self.startImageTransitionTimer()
            
            self.currentImageBag = images
            self.currentId = images.first?.id
            
            let upcomingImg = self.upcomingImage.image
            let nextImg = images.first?.image == upcomingImg ? upcomingImg : images.first?.image
            self.currentImage.image = nextImg
            
            if inTransition {
                self.currentImage.transform = self.startingPoint
                self.currentImage.alpha = 1
                self.upcomingImage.alpha = 0
                self.upcomingImage.removeFromSuperview()
            }
            
            if self.cancel == false {
                self.mediaImageView.addSubview(self.currentImage)
                self.startKenBurnsEffect(withCurrent: self.currentImage, initialImage: !inTransition)
            }
        }
    }
    
    private func startImageDetailTimer() {
        self.imageDetailTimer = Timer.scheduledTimer(
            withTimeInterval: 4.0,
            repeats: false,
            block: { [weak self] (_) in
                self?.layoutImageDetailAttributes()
                self?.displayImageDetails(open: false)
        })
    }
    
    private func startImageDetailVanishTimer() {
        self.imageDetailVanishTimer = Timer.scheduledTimer(
            withTimeInterval: 11.0,
            repeats: false,
            block: { [weak self] (_) in
                DispatchQueue.main.async {
                    UIView.animate(
                        withDuration: 2.0,
                        animations: {
                            self?.imageDetailsView.alpha = 0.0
                    })
                }
        })
    }
    
    private func startImageTransitionTimer() {
        self.imageDetailTimer = Timer.scheduledTimer(
            withTimeInterval: 15.0,
            repeats: false,
            block: { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.shouldChangeImage = true
                    self?.stopTimers()
                }
        })
    }
    
    private func stopTimers() {
        self.imageTransitionTimer?.invalidate()
        self.imageDetailTimer?.invalidate()
        self.imageDetailVanishTimer?.invalidate()
    }
    
    private func displayImageDetails(open: Bool) {
        switch open {
        case true:
            self.openImageDetails()
            
        case false:
            self.collapsedImageDetails()
        }
    }
    
    private func openImageDetails() {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 1.0,
                delay: 0.0,
                usingSpringWithDamping: 0.0,
                initialSpringVelocity: 0.0,
                options: .curveEaseInOut,
                animations: { [weak self] in
                    guard let this = self else {return}
                    this.imageDetailUsernameLabel.isHidden = false
                    this.imageDetailsView.alpha = 1
                    this.imageDetailViewLeadingConstraint.constant = this.openEdgeConstraintConstant
                    this.imageDetailViewTrailingConstraint.constant = this.openEdgeConstraintConstant
                    this.imageDetailViewHeightConstraint.constant = this.openHeightConstant
                }
            )
        }
    }
    
    private func collapsedImageDetails() {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 2.0,
                delay: 0.0,
                usingSpringWithDamping: 0.0,
                initialSpringVelocity: 0.0,
                options: .curveEaseInOut,
                animations: { [weak self] in
                    guard let this = self else {return}
                    this.imageDetailUsernameLabel.isHidden = true
                },
                completion: { [weak self] _ in
                    UIView.animate(withDuration: 2.0, animations: {
                        guard let this = self else {return}
                        this.imageDetailUsernameLabel.isHidden = false
                        this.imageDetailsView.alpha = 1
                        this.imageDetailViewLeadingConstraint.constant = this.collapsedEdgeConstraintConstant
                        this.imageDetailViewTrailingConstraint.constant = this.collapsedEdgeConstraintConstant
                        this.imageDetailViewHeightConstraint.constant = this.collapsedHeightConstant
                    })
                }
            )
        }
    }
    
    private func layoutImageDetailAttributes() {
        print(self.currentId ?? "")
        
        DispatchQueue.main.async {
            let model = self.imageModelbag.filter({$0.id == self.currentId})
            self.imageDetailUserProfileImageView.image = model.first?.image
            self.imageDetailUsernameLabel.text = ""
            self.imageDetailDescriptionLabel.text = model.first?.description
            self.imageDetailPrimaryHashtagLabel.text = model.first?.description
        }
    }
    
    
    private func startKenBurnsEffect(withCurrent imageView: UIImageView, initialImage: Bool) {
        self.currentImage = imageView
        
        let duration: TimeInterval = initialImage ? 1.0 : 20.0
        UIView.animate(
            withDuration: duration,
            animations: {
                switch initialImage || self.shouldChangeImage {
                case false:
                    self.currentImage.transform = self.startingPoint
                case true:
                    self.currentImage.alpha = 1
                }
        },
            completion: { [weak self] (_) in
                switch self?.shouldChangeImage == true {
                case true:
                    self?.shouldChangeImage = false
                    self?.imageViewMetamorphosis()
                    
                case false:
                    self?.recursiveMetamorphosis()
                }
        })
    }
    
    private func imageViewMetamorphosis() {
        print(self.currentImageBag.count)
        
        self.currentImageBag.removeFirst()
        self.imageModelbag.removeFirst()
        
        self.currentIndex += 1
        
        if self.currentImageBag.count == 0 {
            self.stopTimers()
            self.imageDetailsView.alpha = 0
            self.skipCount += 20
            self.pullImages(skip: self.skipCount)
        } else {
            self.currentIndex += 1
            let bag = self.currentImageBag
            guard let upcomingImage = bag.first?.image else {return}
            self.upcomingImage.image = upcomingImage
            self.mediaImageView.addSubview(self.upcomingImage)
            
            UIView.animate(
                withDuration: 1.0,
                animations: {
                    self.imageDetailsView.alpha = 0
                    self.currentImage.alpha = 0
                    self.upcomingImage.alpha = 1
            },
                completion: { [weak self] (_) in
                    self?.processNew(images: bag, inTransition: true)
            })
        }
    }
    
    private func recursiveMetamorphosis() {
        UIView.animate(
            withDuration: 15.0,
            animations: {
                self.currentImage.transform = .identity
        },
            completion: { [weak self] (_) in
                guard let imgView = self?.currentImage else {return}
                self?.startKenBurnsEffect(withCurrent: imgView, initialImage: false)
        })
    }
    
    private func addGestureToDetails() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openDetails))
        self.imageDetailsView.addGestureRecognizer(tap)
    }
    
    private func addGestureToView() {
        let long = UILongPressGestureRecognizer(target: self, action: #selector(self.scanThroughImages))
        self.view.addGestureRecognizer(long)
    }
    
    private func swipeGestureView() {
        let long = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeView))
        self.view.addGestureRecognizer(long)
    }
    
    
    @objc private func scanThroughImages() {
        DispatchQueue.main.async {
            self.cancel = true
            
            self.iterateThrough(images: self.primaryImageBag)
        }
    }
    
    @objc private func swipeView() {
        DispatchQueue.main.async {
            print("Liked Image")
        }
    }
    
    private func iterateThrough(images: [HoldImageModel]) {
        var bag = images

        self.currentImage.image = bag.first?.image
        
        UIView.animate(withDuration: 0.3, animations: {
            bag.removeFirst()
            
            self.iterateThrough(images: bag)
        })
    }
    
    @objc private func openDetails() {
        DispatchQueue.main.async {
            switch self.detailsAreOpen {
            case true:
                self.shouldChangeImage = true
                self.detailsAreOpen = false
                self.collapsedImageDetails()
                
            case false:
                self.shouldChangeImage = false
                self.detailsAreOpen = true
                self.openImageDetails()
            }
        }
    }
    
    @objc private func openRightMenu() {
        DispatchQueue.main.async {
            
            
        }
    }
}
