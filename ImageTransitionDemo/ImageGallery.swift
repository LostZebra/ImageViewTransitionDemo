//
//  ImageGallery.swift
//  ImageTransitionDemo
//
//  Created by xiaoyong on 15/5/3.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import UIKit

class ImageGallery: UIViewController, UIScrollViewDelegate {
    private var imageScrollView: UIScrollView!
    private var imagePageControl: UIPageControl?
    private var descriptionLabel: UILabel!
    
    private var initialIndex: Int!
    private var currentIndex: Int!
    
    private var screenWidth: CGFloat!
    private var screenHeight: CGFloat!
    
    private var sourceImagesInfo: [(frame: CGRect, description: String, imageView: UIImageView)]!
    private var targetImages: [UIImage]!
    private var targetImageUrls: [NSURL]!
    
    var imageViews: [UIImageView]! = [UIImageView]()
    
    var delegate: ImageScrollViewDelegate!
    
    // Image viewcontroller dismiss delegate
    var viewControllerDismissProtocol: FullImageControllerDelegate!
    
    init(initialIndex: Int, sourceImagesInfo: [(frame: CGRect, description: String, imageView: UIImageView)], targetImages: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        // Initialization
        self.initialIndex = initialIndex
        self.currentIndex = initialIndex
        self.sourceImagesInfo = sourceImagesInfo
        self.targetImages = targetImages
    }
    
    /// Initialize all UI elements
    private func prepareUIElements() {
        // Background
        self.view.backgroundColor = UIColor.blackColor()
        // Scrollview for all images
        self.imageScrollView = UIScrollView()
        self.imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.imageScrollView.pagingEnabled = true
        self.imageScrollView.delegate = self
        // Pagecontroll for image positions
        if sourceImagesInfo.count > 1 {
            self.imagePageControl = UIPageControl()
            self.imagePageControl!.translatesAutoresizingMaskIntoConstraints = false
            self.imagePageControl!.numberOfPages = sourceImagesInfo.count
            self.imagePageControl!.currentPage = initialIndex
            self.imagePageControl!.sizeToFit()
        }
        // Label for image descriptions
        self.descriptionLabel = UILabel()
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.backgroundColor = UIColor.clearColor()
        self.descriptionLabel.text = " " + sourceImagesInfo[initialIndex].description
        self.descriptionLabel.textColor = UIColor.whiteColor()
    }
    
    /// Add view constraints
    private func addConstraints() {
        self.view.addSubview(imageScrollView)
        self.view.addSubview(descriptionLabel)
        if imagePageControl != nil {
            self.view.addSubview(imagePageControl!)
        }
        
        self.imageScrollView.frame = self.view.bounds
        self.imageScrollView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.FlexibleHeight.rawValue | UIViewAutoresizing.FlexibleWidth.rawValue)
        // Add constraints
        let defaultLayoutFormat = NSLayoutFormatOptions(rawValue: 0)
        let defaultLayoutRelation = NSLayoutRelation.Equal
        let layoutAttributeCenterX = NSLayoutAttribute.CenterX
        
//        var scaleFactor = UIScreen.mainScreen().scale
        
        var viewBindingDict = [String: AnyObject]()
        viewBindingDict["imagePageControl"] = imagePageControl
        viewBindingDict["descriptionLabel"] = descriptionLabel
        
        var constraintsArray = [NSLayoutConstraint]()
        constraintsArray.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[descriptionLabel]-0-|", options: defaultLayoutFormat, metrics: nil, views: viewBindingDict))
        constraintsArray.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:[descriptionLabel(==40)]-0-|", options: defaultLayoutFormat, metrics: nil, views: viewBindingDict))
        if imagePageControl != nil {
            constraintsArray.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:[imagePageControl]-10-[descriptionLabel]", options: defaultLayoutFormat, metrics: nil, views: viewBindingDict))
            constraintsArray.append(NSLayoutConstraint(item: imagePageControl!, attribute: layoutAttributeCenterX, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeCenterX, multiplier: 1.0, constant: 0.0))
        }
        
        self.view.addConstraints(constraintsArray)
    }
    
    /// Load all images, currently only pre-defined images supported
    private func loadImages(initialPresenting: Bool = true) {
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
        for i in 0..<self.sourceImagesInfo.count {
            var frame: CGRect = CGRectZero
            if (i == initialIndex && initialPresenting) {
                frame = CGRectMake(screenWidth * CGFloat(i) + sourceImagesInfo[i].frame.origin.x, sourceImagesInfo[i].frame.origin.y, sourceImagesInfo[i].frame.width, sourceImagesInfo[i].frame.height)
            }
            else {
                frame = CGRectMake(screenWidth * CGFloat(i), 0.0, screenWidth, screenHeight)
            }
            let imageView = UIImageView(frame: frame)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit;
            imageView.image = i != initialIndex ? targetImages[i] : sourceImagesInfo[i].imageView.image
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didDismiss")))
            imageViews.append(imageView)
            self.imageScrollView.addSubview(imageView)
        }
        
        self.imageScrollView.contentSize = CGSizeMake(screenWidth * CGFloat(targetImages.count), screenHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
        self.prepareUIElements()
        self.addConstraints()
        // Scroll to certain index
        self.imageScrollView.setContentOffset(CGPointMake(UIScreen.mainScreen().bounds.width * CGFloat(initialIndex), 0.0), animated: true)
        // Load images
        self.loadImages()
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        currentIndex = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width))
        if imagePageControl != nil {
            imagePageControl!.currentPage = currentIndex
        }
        descriptionLabel.text = " " + sourceImagesInfo[currentIndex].description
    }
    
    @objc private func didDismiss() {
        let screenSize = UIScreen.mainScreen().bounds
        let selectedImageView = self.imageViews[currentIndex]
        
        selectedImageView.frame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height)
        
        (self.delegate as! UIViewController).view.addSubview(selectedImageView)
        
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.delegate.imageScrollViewDidDismiss(self.currentIndex, imageView: selectedImageView, isInitialIndex: self.currentIndex == self.initialIndex)
        })
    }
    
    // MARK: Ignore this part
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection == nil {
            return
        }
        
        if previousTraitCollection?.verticalSizeClass != self.traitCollection.verticalSizeClass {
            for i in 0..<imageViews.count {
                imageViews[i].removeFromSuperview()
            }
        }
        
        self.loadImages(false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
