//
//  FullImageController.swift
//  ImageTransitionDemo
//
//  Created by xiaoyong on 15/5/3.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import UIKit

protocol FullImageControllerDelegate {
    func fullImageControllerDidDismissed(fullImageView: UIImageView)
}

protocol ImageScrollViewDelegate {
    func imageScrollViewDidDismiss(index: Int, imageView: UIImageView)
}

class FullImageController: UIViewController {
    private var oriFrame: CGRect!
    
    private var fullImage: UIImage!
    
    var fullImageView: UIImageView!
    
    var delegate: FullImageControllerDelegate!

    init(image: UIImage, oriFrame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.fullImage = image
        self.oriFrame = oriFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background
        self.view.backgroundColor = UIColor.blackColor()
        // Do any additional setup after loading the view.
        fullImageView = UIImageView(frame: oriFrame)
        fullImageView.image = fullImage
        fullImageView.contentMode = UIViewContentMode.ScaleAspectFit
        fullImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didDismiss")))
        fullImageView.userInteractionEnabled = true
        self.view.addSubview(fullImageView)
    }
    
    @objc private func didDismiss() {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.delegate.fullImageControllerDidDismissed(self.fullImageView)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
