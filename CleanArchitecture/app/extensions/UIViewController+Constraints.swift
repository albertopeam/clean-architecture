//
//  UIViewController+Constraints.swift
//  CleanArchitecture
//
//  Created by Alberto on 02/06/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addStickyView(_ newView: UIView) {
        view.addSubview(newView)
        NSLayoutConstraint.activate([
            newView.leftAnchor.constraint(equalTo: view.leftAnchor),
            newView.topAnchor.constraint(equalTo: view.topAnchor),
            newView.rightAnchor.constraint(equalTo: view.rightAnchor),
            newView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
}
