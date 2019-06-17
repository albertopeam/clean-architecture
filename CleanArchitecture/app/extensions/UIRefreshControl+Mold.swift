//
//  UIRefreshControl+Mold.swift
//  CleanArchitecture
//
//  Created by Alberto on 02/06/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import UIKit.UIRefreshControl

extension UIRefreshControl {
    
    static var mold: UIRefreshControl {
        let refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.tintColor = .gray
        return refreshControl
    }
    
}
