//
//  CurrentWeatherViewController.swift
//  CleanArchitecture
//
//  Created by Alberto on 22/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit.UIViewController
import CoreLocation
//TODO: tests: logic, future/promise
//TODO: move tests dir weather/weather-current
//TODO: KIF tests y vemos...
class CurrentWeatherViewController: UIViewController {
    
    private var presenter: CurrentWeatherPresenter
    private var reloadButton: UIBarButtonItem!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    init(presenter: CurrentWeatherPresenter) {
        self.presenter = presenter
        super.init(nibName: "CurrentWeatherViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Current Location Weather"
        reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh,
                                       target: self,
                                       action: #selector(reload))
        reload()
    }
    
    @objc private func reload() {
        presenter.current()
    }
}

extension CurrentWeatherViewController: CurrentWeatherViewProtocol {

    func show(viewModel: CurrentWeatherViewModel) {
        cityLabel.text = viewModel.city
        descriptionLabel.text = viewModel.description
        temperatureLabel.text = viewModel.temperature
        pressureLabel.text = viewModel.pressure
        humidityLabel.text = viewModel.humidity
        windSpeedLabel.text = viewModel.windSpeed
    }
    
    func error(message: String) {
        presentAlert(title: "Error", message: message, button: "Ok")
    }
    
    func askLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func hideLoading() {
        loadingView.stopAnimating()
        navigationItem.rightBarButtonItem = reloadButton
    }
    
    func showLoading() {
        loadingView.startAnimating()
        navigationItem.rightBarButtonItem = nil
    }
    
}

extension CurrentWeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            presenter.current()
        }
    }
    
}

