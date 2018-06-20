//
//  WeatherViewController.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, WeatherOutputProtocol {
    
    
    @IBOutlet weak var tableView: UITableView!
    private var items:Array<InstantWeather> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "weather_cell")
        let weather = WeatherComponent.assemble(apiKey: Constants.openWeatherApiKey, cities: ["A Coruña", "Lugo", "Ourense", "Pontevedra"])
        weather.current(output: self)
    }

    func onWeather(items: Array<InstantWeather>) {
        self.items = items
        tableView.reloadData()
    }
    
    func onWeatherError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
