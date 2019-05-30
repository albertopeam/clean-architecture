//
//  UINavigationTestTool.swift
//  CleanArchitectureUITests
//
//  Created by Penas Amor, Alberto on 23/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import UIKit

class UITestNavigationTool<T: UIViewController> {
    
    private(set) var rootWindow: UIWindow!
    private(set) var navigationController:UITestNavigationViewController?
    
    func setUp(withViewController viewController: T) {
        rootWindow = UIWindow(frame: UIScreen.main.bounds)
        rootWindow.isHidden = false
        navigationController = UITestNavigationViewController(rootViewController: viewController)
        rootWindow.rootViewController = navigationController
        rootWindow.makeKeyAndVisible()
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }
    
    func tearDown() {
        guard let rootWindow = rootWindow else {
            XCTFail("UINavigationTestTool tearDown() was called without setUp() being called first")
            return
        }
        guard let navigationController = rootWindow.rootViewController as? UINavigationController  else {
            XCTFail("UINavigationTestTool tearDown() doesn't have a UINavigationController")
            return
        }
        guard let rootViewController = navigationController.viewControllers.last else {
            XCTFail("UINavigationTestTool tearDown() doesn't have a UINavigationController with a view controller")
            return
        }
        rootViewController.viewWillDisappear(false)
        rootViewController.viewDidDisappear(false)
        rootWindow.rootViewController = nil
        rootWindow.isHidden = true
        self.rootWindow = nil
    }
    
}
