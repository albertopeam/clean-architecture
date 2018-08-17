//
//  UITest.swift
//  CleanArchitectureUITests
//
//  Created by Penas Amor, Alberto on 20/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import UIKit

//https://albertodebortoli.com/2018/03/12/easy-view-controller-unit-testing/
class UITestTool<T: UIViewController> {
    
    private(set) var rootWindow: UIWindow!
    
    func setUp(withViewController viewController: T) {
        rootWindow = UIWindow(frame: UIScreen.main.bounds)
        rootWindow.isHidden = false
        rootWindow.rootViewController = viewController
        rootWindow.makeKeyAndVisible()
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }
    
    func tearDown() {
        guard let rootWindow = rootWindow,
            let rootViewController = rootWindow.rootViewController as? T  else {
                XCTFail("UITestTool tearDown() was called without setUp() being called first")
                return
        }
        rootViewController.viewWillDisappear(false)
        rootViewController.viewDidDisappear(false)
        rootWindow.rootViewController = nil
        rootWindow.isHidden = true
        self.rootWindow = nil
    }
}
