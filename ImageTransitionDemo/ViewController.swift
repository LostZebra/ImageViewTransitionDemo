//
//  ViewController.swift
//  ImageTransitionDemo
//
//  Created by xiaoyong on 15/5/3.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, FullImageControllerDelegate, ImageScrollViewDelegate {
    // Constants
    let defaultFormatOption = NSLayoutFormatOptions(rawValue: 0)
    let defaultLayoutRelation = NSLayoutRelation.Equal
    let layoutAttributeCenterX = NSLayoutAttribute.CenterX
    let layoutAttributeCenterY = NSLayoutAttribute.CenterY
    let layoutAttributeTop = NSLayoutAttribute.Top
    let layoutAttributeWidth = NSLayoutAttribute.Width
    let layoutAttributeHeight = NSLayoutAttribute.Height
    
    private var image: UIImage!
    private var imageView: UIImageView!
    
    private var imageCollectionView: UICollectionView!
    private var sourceImagesInfo: [(frame: CGRect, description: String, imageView: UIImageView)]! = []
    private var targetImages: [UIImage]! = [UIImage]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background
        self.view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view, typically from a nib.
        image = UIImage(named: "small_thumbnail.jpg")
        imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(imageView)
        // Add tap recognizer
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("presentFullImage")))
        imageView.userInteractionEnabled = true
        // Add image source for image collectionview
        for i in 1...4 {
            let mediate_thumbnail = String(i) + "_mediate.jpg"
            let small_thumnail = String(i) + ".jpg"
            targetImages.append(UIImage(named: mediate_thumbnail)!)
            sourceImagesInfo.append(frame: CGRectZero, description: small_thumnail, imageView: UIImageView())
        }
        // Add image collectionview
        imageCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: constructCollectionViewLayout())
        imageCollectionView.backgroundColor = UIColor.whiteColor()
        imageCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        self.view.addSubview(imageCollectionView)
        // Add constraints
        self.addConstraints()
    }
    
    private func addConstraints() {
        var viewBindingDictionary = [String: AnyObject]()
        viewBindingDictionary["imageView"] = imageView
        viewBindingDictionary["imageCollectionView"] = imageCollectionView

        var constraintsArray = [NSLayoutConstraint]()
        constraintsArray.append(NSLayoutConstraint(item: imageView, attribute: layoutAttributeCenterX, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeCenterX, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: imageView, attribute: layoutAttributeTop, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeTop, multiplier: 1.0, constant:94.0))
        constraintsArray.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(==60)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary))
        constraintsArray.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(==60)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary))
        constraintsArray.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView]-120-[imageCollectionView(>=180)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary))
        constraintsArray.append(NSLayoutConstraint(item: imageCollectionView, attribute: layoutAttributeWidth, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeWidth, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraints(constraintsArray)
    }
    
    /// Get UICollectionViewFlowLayout
    private func constructCollectionViewLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.itemSize = CGSizeMake(60.0, 60.0)
        flowLayout.sectionInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
        
        return flowLayout
    }
    
    @objc func presentFullImage() {
        let fullImageViewController = FullImageController(image: UIImage(named: "mediate_thumbnail.jpg")!, oriFrame: imageView.frame)
        fullImageViewController.delegate = self
        
        self.presentViewController(fullImageViewController, animated: false) { () -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                fullImageViewController.fullImageView.layer.transform = self.imageView.getTransform(toViewController: fullImageViewController)
            }, completion: { (completed) -> Void in
                // Do nothing
            })
        }
    }
    
    // MARK: UICollectionViewDataSource & UICollectionViewDelegate
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let imageView = UIImageView(frame: CGRectMake(0.0, 0.0, 60.0, 60.0))
        imageView.image = targetImages[indexPath.row]
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        cell.addSubview(imageView)
        
//        var tempSuperview = imageView.superview
//        while tempSuperview!.superview != nil {
//            tempSuperview = tempSuperview!.superview
//        }
        
        let attributes = self.imageCollectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let rect = attributes!.frame
        
        sourceImagesInfo[indexPath.row].frame = CGRectMake(rect.origin.x, imageCollectionView.frame.origin.y + rect.origin.y, rect.width, rect.height)
        sourceImagesInfo[indexPath.row].imageView = imageView
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedItemIndex = indexPath.row
        let imageView = collectionView.cellForItemAtIndexPath(indexPath)
        let imageGallery = ImageGallery(initialIndex: selectedItemIndex, sourceImagesInfo: sourceImagesInfo, targetImages: targetImages)
        imageGallery.delegate = self
        
        self.presentViewController(imageGallery, animated: false) { () -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                imageGallery.imageViews[selectedItemIndex].layer.transform = imageView!.getTransform(selectedItemIndex, sourceFrame: self.sourceImagesInfo[selectedItemIndex].frame, toViewController: nil)
                }, completion: { (completed) -> Void in
                    imageGallery.imageViews[selectedItemIndex].image = self.targetImages[selectedItemIndex]
            })
        }
    }
    
    // MARK: ImageScrollViewDelegate
    
    func imageScrollViewDidDismiss(index: Int, imageView: UIImageView, isInitialIndex: Bool) {
        let tempImage = sourceImagesInfo[index].imageView.image
        sourceImagesInfo[index].imageView.image = nil
        sourceImagesInfo[index].imageView.backgroundColor = UIColor.whiteColor()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            imageView.layer.transform = isInitialIndex ? CATransform3DIdentity : imageView.getTransform(self.sourceImagesInfo[index].frame)
            }) { (comleted) -> Void in
                imageView.removeFromSuperview()
                self.sourceImagesInfo[index].imageView.image = tempImage
        }
    }
    
    // MARK: FullImageControllerDelegate
    
    func fullImageControllerDidDismissed(fullImageView: UIImageView) {
        let tempImage = self.imageView.image
        self.imageView.image = nil
        self.imageView.backgroundColor = UIColor.whiteColor()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            fullImageView.layer.transform = self.imageView.layer.transform
        }) { (comleted) -> Void in
            fullImageView.removeFromSuperview()
            self.imageView.image = tempImage
        }
    }
    
    // MARK: Ignore this part
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection == nil {
            return
        }
        
        // Recalculate the frame information of all the subviews in the UICollectionView
        if previousTraitCollection?.verticalSizeClass != self.traitCollection.verticalSizeClass {
            self.imageCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension UIView {
    /// Get a CATransform3D from source view to target viewcontroller
    ///
    /// :param: toViewController Target viewcontroller of the transition
    func getTransform(toViewController to: UIViewController?) -> CATransform3D {
        let targetSize = to == nil ? UIScreen.mainScreen().bounds : to!.view.bounds
        
        let oriCenter = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        let newCenter = CGPointMake(CGRectGetMidX(targetSize), CGRectGetMidY(targetSize))
        
        let scaleFactor = self.traitCollection.verticalSizeClass == .Regular ? targetSize.width / self.frame.width : targetSize.height / self.frame.height
        
        let scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        return CATransform3DTranslate(scaleTransform, (newCenter.x - oriCenter.x) / scaleFactor, (newCenter.y - oriCenter.y) / scaleFactor, 0.0)
    }
    
    /// Get a CATransform3D from source image in a collectionview to target viewcontroller
    ///
    /// :param: index Index of image tapped
    /// :param: sourceFrame Frame of the source view
    /// :param: toViewController Target viewcontroller of the transition
    func getTransform(index:Int, sourceFrame: CGRect, toViewController to: UIViewController?) -> CATransform3D {
        let targetSize = to == nil ? UIScreen.mainScreen().bounds : to!.view.bounds
        
        let oriCenter = CGPointMake(CGRectGetMidX(sourceFrame) + targetSize.width * CGFloat(index), CGRectGetMidY(sourceFrame))
        
        let newCenter = CGPointMake(CGRectGetMidX(targetSize) + targetSize.width * CGFloat(index), CGRectGetMidY(targetSize))
        
        let scaleFactor = self.traitCollection.verticalSizeClass == .Regular ? targetSize.width / sourceFrame.width : targetSize.height / sourceFrame.height
        
        let scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        return CATransform3DTranslate(scaleTransform, (newCenter.x - oriCenter.x) / scaleFactor, (newCenter.y - oriCenter.y) / scaleFactor, 0.0)
    }

    /// Get a CATransform3D from source frame to target frame
    ///
    /// :param: toFrame Target frame
    func getTransform(toFrame: CGRect) -> CATransform3D {
        let oriCenter = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        let newCenter = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame))
        
        let scaleFactor = self.traitCollection.verticalSizeClass == .Regular ? toFrame.width / self.frame.width : toFrame.height / self.frame.height
        
        let scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        return CATransform3DTranslate(scaleTransform, (newCenter.x - oriCenter.x) / scaleFactor, (newCenter.y - oriCenter.y) / scaleFactor, 0.0)
    }
}
