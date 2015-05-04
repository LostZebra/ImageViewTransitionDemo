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
    
    private var sourceImagesInfo: [(frame: CGRect, description: String, image: UIImageView)]!
    private var targetImages: [UIImage]!
    private var targetImageUrls: [NSURL]!
    
    var imageViews: [UIImageView]! = [UIImageView]()
    
    var imageScrollViewDelegate: ImageScrollViewDelegate!
    
    // Image viewcontroller dismiss delegate
    var viewControllerDismissProtocol: FullImageControllerDelegate!
    
    init(initialIndex: Int, sourceImagesInfo: [(frame: CGRect, description: String, image: UIImageView)], targetImages: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        // Initialization
        self.initialIndex = initialIndex
        self.sourceImagesInfo = sourceImagesInfo
        self.targetImages = targetImages
    }
    
    /// Initialize all UI elements
    private func prepareUIElements() {
        // Background
        self.view.backgroundColor = UIColor.blackColor()
        // Scrollview for all images
        self.imageScrollView = UIScrollView()
        self.imageScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.imageScrollView.pagingEnabled = true
        self.imageScrollView.delegate = self
        // Pagecontroll for image positions
        if sourceImagesInfo.count > 1 {
            self.imagePageControl = UIPageControl()
            self.imagePageControl!.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.imagePageControl!.numberOfPages = sourceImagesInfo.count
            self.imagePageControl!.currentPage = initialIndex
            self.imagePageControl!.sizeToFit()
        }
        // Label for image descriptions
        self.descriptionLabel = UILabel()
        self.descriptionLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        self.imageScrollView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        // Add constraints
        let defaultLayoutFormat = NSLayoutFormatOptions(0)
        let defaultLayoutRelation = NSLayoutRelation.Equal
        let layoutAttributeCenterX = NSLayoutAttribute.CenterX
        
        var viewBindingDict = NSMutableDictionary()
        viewBindingDict.setValue(imagePageControl, forKey: "imagePageControl")
        viewBindingDict.setValue(descriptionLabel, forKey: "descriptionLabel")
        var constraintsArray = NSMutableArray()
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[descriptionLabel]-0-|", options: defaultLayoutFormat, metrics: nil, views: viewBindingDict as [NSObject : AnyObject]))
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("V:[descriptionLabel(==40)]-0-|", options: defaultLayoutFormat, metrics: nil, views: viewBindingDict as [NSObject : AnyObject]))
        if imagePageControl != nil {
            constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("V:[imagePageControl]-10-[descriptionLabel]", options: defaultLayoutFormat, metrics: nil, views: viewBindingDict as [NSObject : AnyObject]))
            constraintsArray.addObject(NSLayoutConstraint(item: imagePageControl!, attribute: layoutAttributeCenterX, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeCenterX, multiplier: 1.0, constant: 0.0))
        }
        self.view.addConstraints(constraintsArray as [AnyObject])
    }
    
    /// Load all images, currently only pre-defined images supported
    private func loadImages() {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        for i in 0..<self.sourceImagesInfo.count {
            var frame = CGRectMake(i == initialIndex ? screenWidth * CGFloat(i) + sourceImagesInfo[i].frame.origin.x : screenWidth * CGFloat(i), i == initialIndex ? sourceImagesInfo[i].frame.origin.y : 0.0, i == initialIndex ? sourceImagesInfo[i].frame.width : screenWidth, i == initialIndex ? sourceImagesInfo[i].frame.height :screenHeight)
            var imageView = UIImageView(frame: frame)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit;
            imageView.image = targetImages[i]
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didDismiss")))
            imageViews.append(imageView)
            self.imageScrollView.addSubview(imageView)
        }
        
        self.imageScrollView.contentSize = CGSizeMake(screenWidth * CGFloat(targetImages.count), screenHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.imageScrollViewDelegate.imageScrollViewDidDismiss(self.currentIndex, imageView: self.imageViews[self.currentIndex])
        })
    }
    
    // MARK: Ignore this part
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
