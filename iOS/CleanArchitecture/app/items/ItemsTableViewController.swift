//
//  ItemsTableViewController.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class ItemsTableViewController: UITableViewController {
    
    var items:Array<Item> = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Items"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        items = [Item(name: "Places", target: NearbyPlacesAssembler.assemble()), Item(name: "Weather", target: WeatherAssembler.assemble())]
        self.tableView.reloadData()
    }

}

extension ItemsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell_id")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell_id")
        }
        cell.textLabel?.text = items[indexPath.row].name
        return cell
    }
}

extension ItemsTableViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(items[indexPath.row].target, animated: true)
    }
}
