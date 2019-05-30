//
//  CurrentWeatherViewController.swift
//  CleanArchitecture
//
//  Created by Alberto on 22/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit.UIViewController
import CoreLocation
//TODO: tests: interactor+presenter
//TODO: future/promise: añadir más tests
    //TODO: check not responding more than once, NOW it does
//TODO: CI build?
//TODO: readme
    //TODO: sundell promises
    //TODO: UITESTS
//TODO: swiftlint
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
    
    enum AccessibilityIdentifiers {
        static let loading = "CurrentWeatherViewController.loading"
        static let city = "CurrentWeatherViewController.city"
        static let description = "CurrentWeatherViewController.description"
        static let temperature = "CurrentWeatherViewController.temperature"
        static let pressure = "CurrentWeatherViewController.pressure"
        static let humidity = "CurrentWeatherViewController.humidity"
        static let windSpeed = "CurrentWeatherViewController.windspeed"
    }
    
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
        loadingView.accessibilityIdentifier = AccessibilityIdentifiers.loading
        cityLabel.accessibilityIdentifier = AccessibilityIdentifiers.city
        descriptionLabel.accessibilityIdentifier = AccessibilityIdentifiers.description
        temperatureLabel.accessibilityIdentifier = AccessibilityIdentifiers.temperature
        pressureLabel.accessibilityIdentifier = AccessibilityIdentifiers.pressure
        humidityLabel.accessibilityIdentifier = AccessibilityIdentifiers.humidity
        windSpeedLabel.accessibilityIdentifier = AccessibilityIdentifiers.windSpeed
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
        cityLabel.isHidden = false
        descriptionLabel.isHidden = false
        temperatureLabel.isHidden = false
        pressureLabel.isHidden = false
        humidityLabel.isHidden = false
        windSpeedLabel.isHidden = false
        descriptionLabel.text = viewModel.description
        temperatureLabel.text = viewModel.temperature
        pressureLabel.text = viewModel.pressure
        humidityLabel.text = viewModel.humidity
        windSpeedLabel.text = viewModel.windSpeed
    }
    
    func error(message: String) {
        cityLabel.isHidden = true
        descriptionLabel.isHidden = true
        temperatureLabel.isHidden = true
        pressureLabel.isHidden = true
        humidityLabel.isHidden = true
        windSpeedLabel.isHidden = true
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

