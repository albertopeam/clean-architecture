//
//  UIRobot.swift
//  CleanArchitectureUITests
//
//  Created by Alberto on 23/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import KIF
import UIKit.UIViewController
@testable import CleanArchitecture

class UIRobot {
    
    private var originalRootViewController: UIViewController?
    private var rootViewController: UIViewController? {
        get {
            return UIApplication.shared.delegate?.window??.rootViewController
        }
        
        set(newRootViewController) {
            UIApplication.shared.delegate?.window??.rootViewController = newRootViewController
        }
    }
    var tester: KIFUITestActor?
    
    init(test: XCTestCase) {
        self.tester = test.tester()
    }
    
    deinit {
        rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
        rootViewController = UIViewController()
        originalRootViewController = nil
        tester = nil
    }
    
    /**
     Must used only to present a viewcontroller without navigation actions
     */
    func present(viewController: UIViewController) {
        originalRootViewController = rootViewController
        rootViewController = viewController
    }
    
    /**
     Must used only to push a viewcontroller that can trigger pushes to the navigation
     */
    @discardableResult
    func root(viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        originalRootViewController = rootViewController
        rootViewController = nav
        return nav
    }
}
