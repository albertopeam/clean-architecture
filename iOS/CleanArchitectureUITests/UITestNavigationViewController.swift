//
//  UITestNavigationViewController.swift
//  CleanArchitectureUITests
//
//  Created by Penas Amor, Alberto on 23/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class UITestNavigationViewController: UINavigationController {
    
    private(set) var controllers:Array<UIViewController> = Array()

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        controllers.append(viewController)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: animated)
        return controllers.removeLast()
    }
    
}
