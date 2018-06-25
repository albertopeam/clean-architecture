//
//  WeatherViewController.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, WeatherViewProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    private var items:Array<InstantWeather> = []
    private let presenter:WeatherPresenterProtocol
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    init(presenter:WeatherPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "WeatherViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "weather_cell")
        presenter.weathers()
    }
    
    func newState(viewModel: WeatherViewModel) {
        if let weathers = viewModel.weathers {
            self.items = weathers
            tableView.reloadData()
        }
        if let error = viewModel.error {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension WeatherViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : WeatherTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "weather_cell", for: indexPath) as! WeatherTableViewCell
        let weather = items[indexPath.row]
        cell.draw(weather: weather)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
}

extension WeatherViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
}
