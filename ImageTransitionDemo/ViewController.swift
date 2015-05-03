//
//  ViewController.swift
//  ImageTransitionDemo
//
//  Created by xiaoyong on 15/5/3.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FullImageControllerDelegate {
    // Constants
    let defaultFormatOption = NSLayoutFormatOptions(rawValue: 0)
    let defaultLayoutRelation = NSLayoutRelation.Equal
    let layoutAttributeCenterX = NSLayoutAttribute.CenterX
    let layoutAttributeCenterY = NSLayoutAttribute.CenterY
    
    private var image: UIImage!
    private var imageView: UIImageView!
    
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
        // Add constraints
        self.addConstraints()
    }
    
    private func addConstraints() {
        var viewBindingDictionary = NSMutableDictionary()
        viewBindingDictionary.setValue(imageView, forKey: "imageView")
        var constraintsArray = NSMutableArray()
        constraintsArray.addObject(NSLayoutConstraint(item: imageView, attribute: layoutAttributeCenterX, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeCenterX, multiplier: 1.0, constant: 0.0))
        constraintsArray.addObject(NSLayoutConstraint(item: imageView, attribute: layoutAttributeCenterY, relatedBy: defaultLayoutRelation, toItem: self.view, attribute: layoutAttributeCenterY, multiplier: 1.0, constant: 0.0))
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(==60)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary as [NSObject : AnyObject]))
        constraintsArray.addObjectsFromArray(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(==60)]", options: defaultFormatOption, metrics: nil, views: viewBindingDictionary as [NSObject : AnyObject]))
      
        self.view.addConstraints(constraintsArray as [AnyObject])
    }
    
    @objc func presentFullImage() {
        let oriCenter = CGPointMake(CGRectGetMidX(imageView.frame), CGRectGetMidY(imageView.frame))
        let oriRatio = image.size.width / image.size.height
        
        let screenSize = UIScreen.mainScreen().bounds
        let screenRatio = screenSize.width / screenSize.height
        
        var scaleFactor = screenSize.width * 2.0 / image.size.width
        
        let newCenter = CGPointMake(screenSize.width / 2.0, screenSize.height / 2.0)
        
        var scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        var translate = CATransform3DTranslate(scaleTransform, newCenter.x - oriCenter.x, newCenter.y - oriCenter.y, 0.0)
        
        var fullImageViewController = FullImageController(image: UIImage(named: "mediate_thumbnail.jpg")!, oriFrame: imageView.frame)
        fullImageViewController.delegate = self
        self.presentViewController(fullImageViewController, animated: false) { () -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                fullImageViewController.fullImageView.layer.transform = translate
            }, completion: { (completed) -> Void in
                //
            })
        }
    }
    
    func fullImageControllerDidDismissed(fullImageView: UIImageView) {
        let oriCenter = CGPointMake(CGRectGetMidX(imageView.frame), CGRectGetMidY(imageView.frame))
        let oriRatio = image.size.width / image.size.height
        
        let screenSize = UIScreen.mainScreen().bounds
        let screenRatio = screenSize.width / screenSize.height
        
        var scaleFactor = screenSize.width * 2.0 / image.size.width
        
        let newCenter = CGPointMake(screenSize.width / 2.0, screenSize.height / 2.0)
        
        var scaleTransform = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0)
        var translate = CATransform3DTranslate(scaleTransform, newCenter.x - oriCenter.x, newCenter.y - oriCenter.y, 0.0)
        
        self.view.addSubview(fullImageView)
//        fullImageView.layer.transform = translate
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

