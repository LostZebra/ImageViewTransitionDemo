//
//  ImageTransitionDemoTests.swift
//  ImageTransitionDemoTests
//
//  Created by xiaoyong on 15/5/3.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import UIKit
import XCTest

class ImageTransitionDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        if #available(iOS 9.0, *) {
            XCUIApplication().launch()
        } else {
            // Fallback on earlier versions
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
