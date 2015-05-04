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
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        imageCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        self.view.addSubview(imageCollectionView)
        // Add constraints
        self.addConstraints()
    }
    
    private func addConstraints() {
        var viewBindingDictionary = NSMutableDictionary()
        viewBindingDictionary.setValue(imageView, forKey: "imageView")
        viewBindingDictionary.setValue(imageCollectionView, forKey: "imageCollectionView")

        var constraintsArray = NSMutableArray()
        constraintsArray.addObject(NSLayoutConstraint(item: imageView, attribute: layoutAttributeCenterX, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeCenterX, multiplier: 1.0, constant: 0.0))
        constraintsArray.addObject(NSLayoutConstraint(item: imageView, attribute: layoutAttributeCenterY, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeCenterY, multiplier: 1.0, constant: -180.0))
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(==60)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary as [NSObject : AnyObject]))
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(==60)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary as [NSObject : AnyObject]))
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView]-120-[imageCollectionView(>=90)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary as [NSObject : AnyObject]))
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageCollectionView]-0-|", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary as [NSObject : AnyObject]))
        
        self.view.addConstraints(constraintsArray as [AnyObject])
    }
    
    /// Get UICollectionViewFlowLayout
    private func constructCollectionViewLayout() -> UICollectionViewFlowLayout {
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 15.0
        flowLayout.minimumLineSpacing = 15.0
        flowLayout.itemSize = CGSizeMake(60.0, 60.0)
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        
        return flowLayout
    }
    
    @objc func presentFullImage() {
        var fullImageViewController = FullImageController(image: UIImage(named: "mediate_thumbnail.jpg")!, oriFrame: imageView.frame)
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
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        var imageView = UIImageView(frame: CGRectMake(0.0, 0.0, 60.0, 60.0))
        imageView.image = targetImages[indexPath.row]
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        cell.addSubview(imageView)
        
        var tempSuperview = imageView.superview
        while tempSuperview!.superview != nil {
            tempSuperview = tempSuperview!.superview
        }
        
        var attributes = self.imageCollectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let rect = attributes!.frame
        
        sourceImagesInfo[indexPath.row].frame = CGRectMake(rect.origin.x, imageCollectionView.frame.origin.y + rect.origin.y, rect.width, rect.height)
        sourceImagesInfo[indexPath.row].imageView = imageView
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var selectedItemIndex = indexPath.row
        var imageView = collectionView.cellForItemAtIndexPath(indexPath)
        var imageGallery = ImageGallery(initialIndex: selectedItemIndex, sourceImagesInfo: sourceImagesInfo, targetImages: targetImages)
        imageGallery.imageScrollViewDelegate = self
        
        self.presentViewController(imageGallery, animated: false) { () -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                imageGallery.imageViews[selectedItemIndex].layer.transform = imageView!.getTransform(selectedItemIndex, sourceFrame: self.sourceImagesInfo[selectedItemIndex].frame, toViewController: nil)
                }, completion: { (completed) -> Void in
                    imageGallery.imageViews[selectedItemIndex].image = self.targetImages[selectedItemIndex]
            })
        }
    }
    
    // MARK: ImageScrollViewDelegate
    
    func imageScrollViewDidDismiss(index: Int, imageView: UIImageView) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            let transform = imageView.layer.transform
            imageView.layer.transform = CATransform3DIdentity
//            imageView.layer.transform = self.sourceImagesInfo[index].imageView.layer.transform
            }) { (comleted) -> Void in
                imageView.removeFromSuperview()
        }
    }
    
    // MARK: FullImageControllerDelegate
    
    func fullImageControllerDidDismissed(fullImageView: UIImageView) {
        let oriCenter = CGPointMake(CGRectGetMidX(imageView.frame), CGRectGetMidY(imageView.frame))
        let oriRatio = image.size.width / image.size.height
        
        let screenSize = UIScreen.mainScreen().bounds
        let screenRatio = screenSize.width / screenSize.height
        
        var scaleFactor = screenSize.width / image.size.width
        
        let newCenter = CGPointMake(screenSize.width / 2.0, screenSize.height / 2.0)
        
        var scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        var translate = CATransform3DTranslate(scaleTransform, newCenter.x - oriCenter.x, newCenter.y - oriCenter.y, 0.0)
        
        self.view.addSubview(fullImageView)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            fullImageView.layer.transform = self.imageView.layer.transform
        }) { (comleted) -> Void in
            fullImageView.removeFromSuperview()
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
        
        let newCenter = CGPointMake(targetSize.width / 2.0, targetSize.height / 2.0)
        
        var scaleFactor = targetSize.width / 60.0
        
        var scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        return CATransform3DTranslate(scaleTransform, (newCenter.x - oriCenter.x) / scaleFactor, (newCenter.y - oriCenter.y) / scaleFactor, 0.0)
    }
    
    /// Get a CATransform3D from source view to target viewcontroller
    ///
    /// :param: index Index of image tapped
    /// :param: sourceFrame Frame of the source view
    /// :param: toViewController Target viewcontroller of the transition
    func getTransform(index:Int, sourceFrame: CGRect, toViewController to: UIViewController?) -> CATransform3D {
        let targetSize = to == nil ? UIScreen.mainScreen().bounds : to!.view.bounds
        
        let oriCenter = CGPointMake(CGRectGetMidX(sourceFrame) + targetSize.width * CGFloat(index), CGRectGetMidY(sourceFrame))
        
        let newCenter = CGPointMake(targetSize.width / 2.0 + targetSize.width * CGFloat(index), targetSize.height / 2.0)
        
        var scaleFactor = targetSize.width / 60.0
        
        var scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        return CATransform3DTranslate(scaleTransform, (newCenter.x - oriCenter.x) / scaleFactor, (newCenter.y - oriCenter.y) / scaleFactor, 0.0)
    }

    /// Get a CATransform3D from source view to target viewcontroller
    ///
    /// :param: index Index of image tapped
    /// :param: sourceFrame Frame of the source view
    /// :param: toViewController Target viewcontroller of the transition
    func getTransform(toFrame: CGRect) -> CATransform3D {
        let oriCenter = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        let newCenter = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame))
        
        var scaleFactor = toFrame.width / self.frame.width
        
        var scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        return CATransform3DTranslate(scaleTransform, newCenter.x - oriCenter.x, newCenter.y - oriCenter.y, 0.0)
    }

}
