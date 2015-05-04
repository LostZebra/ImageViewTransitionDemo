//
//  TransitionProtocol.swift
//  ImageTransitionDemo
//
//  Created by xiaoyong on 15/5/4.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import UIKit

protocol FullImageControllerDelegate {
    func fullImageControllerDidDismissed(fullImageView: UIImageView)
}

protocol ImageScrollViewDelegate {
    func imageScrollViewDidDismiss(index: Int, imageView: UIImageView, isInitialIndex: Bool)
}
