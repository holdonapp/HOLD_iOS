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
    
    private let collapsedHeightConstant: CGFloat = 50
    private let collapsedEdgeConstraintConstant: CGFloat = 45
    
    private let openHeightConstant: CGFloat = 120
    private let openEdgeConstraintConstant: CGFloat = 10
    
    private var imageDetailTimer: Timer?
    private var imageTransitionTimer: Timer?
    private var imagePrefetchTimer: Timer?
    
    private var currentImageBag: [UIImage] = []
    private var upcomingImageBag: [UIImage] = []
    private var currentImage: UIImage?
    private var upcomingImage: UIImage?
    
    var viewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.pullImages()
    }
    
    deinit {
        print("Deinit success - \(self.description)")
    }
}

extension HomeViewController {
    
    private func setup() {
        self.imageDetailsView.alpha = 0
        self.imageDetailsView.layer.cornerRadius = 15
        self.imageDetailUserProfileImageView.layer.cornerRadius = self.imageDetailUserProfileImageView.bounds.width / 2
        self.imageDetailBlurBackgroundFxView.layer.cornerRadius = 15
    }
    
    private func pullImages(){
        
        // Display Loader
        let data = self.createLoaderViewData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
        
        self.viewModel?.pullFirstFiftyImages(skip: 0, completion: { (models, error) in
            
            // Collapse Loader
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            
            let canProceed = (error == nil && !models.isEmpty) ? true : false
            switch canProceed {
            case true:
                self.beginImageCycling(with: models)
                
            case false:
                break
            }
        })
    }
    
    private func beginImageCycling(with bag: [HoldImageModel]){
        
        
        DispatchQueue.main.async {
            guard let model = bag.first else {return}
            let imgView = UIImageView(frame: self.mediaImageView.frame)
            self.mediaImageView.addSubview(imgView)
            imgView.download(link: model.urlString, completion: { [weak self] _ in
                self?.startImageTransitionTimer()
                self?.startImageDetailTimer()
                self?.startImagePrefetchTimer()
            })
        }
    }
    
    private func startImageDetailTimer() {
        self.imageDetailTimer = Timer.scheduledTimer(
            withTimeInterval: 3.0,
            repeats: false,
            block: { [weak self] (_) in
                self?.displayImageDetails(open: false)
        })
    }
    
    private func startImageTransitionTimer() {
        self.imageDetailTimer = Timer.scheduledTimer(
            withTimeInterval: 9.0,
            repeats: false,
            block: { [weak self] (_) in
                self?.displayImageDetails(open: false)
        })
    }
    
    private func startImagePrefetchTimer() {
        self.imageDetailTimer = Timer.scheduledTimer(
            withTimeInterval: 7.0,
            repeats: false,
            block: { [weak self] (_) in
                self?.displayImageDetails(open: false)
        })
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
                    this.imageDetailViewLeadingConstraint.constant = this.openEdgeConstraintConstant
                    this.imageDetailViewHeightConstraint.constant = this.openHeightConstant
                },
                completion: { [weak self] _ in
                    UIView.animate(withDuration: 2.0, animations: {
                        self?.imageDetailsView.alpha = 1
                    })
                }
            )
        }
    }
    
    private func collapsedImageDetails() {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 1.0,
                delay: 0.0,
                usingSpringWithDamping: 0.0,
                initialSpringVelocity: 0.0,
                options: .curveEaseInOut,
                animations: { [weak self] in
                    guard let this = self else {return}
                    this.imageDetailUsernameLabel.isHidden = true
                    this.imageDetailViewLeadingConstraint.constant = this.collapsedEdgeConstraintConstant
                    this.imageDetailViewHeightConstraint.constant = this.collapsedHeightConstant
                },
                completion: { [weak self] _ in
                    UIView.animate(withDuration: 2.0, animations: {
                        self?.imageDetailsView.alpha = 1
                    })
                }
            )
        }
    }
    
    private func stopImageDetailTimer() {
        
    }
    
    private func resetImageDetailTimer() {
        
    }
    
    private func createLoaderViewData() -> ActivityData {
        let data = ActivityData(
            size     : CGSize(width: 50, height: 50),
            message  : "Loading Images...",
            type     : .circleStrokeSpin,
            color    : .holdOrange,
            textColor: .white
        )
        return data
    }
    
}
