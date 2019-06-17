//
//  UIViewController.swift
//  CleanArchitecture
//
//  Created by Alberto on 29/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

public extension UIViewController {
    func presentAlert(title:String, message:String, button:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
