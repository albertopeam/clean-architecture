//
//  UITableView+Mold.swift
//  CleanArchitecture
//
//  Created by Alberto on 02/06/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import UIKit

extension UITableView {
    
    static var mold: UITableView {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.refreshControl = UIRefreshControl.mold
        tableView.alwaysBounceVertical = true
        return tableView
    }
    
}
