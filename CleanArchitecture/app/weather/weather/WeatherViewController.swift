//
//  WeatherViewController.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, WeatherViewProtocol {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
        title = "Galician Weather"
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "weather_cell")
        presenter.weathers()
    }
    
    func newState(viewState: WeatherViewState) {
        if viewState.loading {
            activityIndicator.isHidden = false
        }else{
            activityIndicator.isHidden = true
        }
        if let weathers = viewState.weathers {
            self.items = weathers
            tableView.reloadData()
        }
        if let error = viewState.error {
            self.presentAlert(title: "Error", message: error, button: "Ok")
        }
    }
}

extension WeatherViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weather_cell", for: indexPath) as? WeatherTableViewCell else {
            fatalError("WeatherTableViewCell not registered")
        }
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
