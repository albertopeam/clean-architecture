//
//  AppDelegate.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().isTranslucent = false
        var navController: UINavigationController?
        if NSClassFromString("XCTest") == nil {
            navController = UINavigationController(rootViewController: ItemsTableViewController())
        } else {
            navController = UINavigationController(rootViewController: UIViewController())
        }
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
        return true
    }

}

