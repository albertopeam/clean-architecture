//
//  AirQualityViewController.swift
//  CleanArchitecture
//
//  Created by Alberto on 24/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit
import CoreLocation

//TODO: promise in main thread, pe LocationManager in main, it could not work
//TODO: generics
//TODO: remove try! from await, it should be captured by async block
//TODO: async should be 'ínvisible', if possible

class AirQualityViewController: UIViewController, AirQualityViewProtocol {
    
    @IBOutlet weak var no2Label: UILabel!
    @IBOutlet weak var o3Label: UILabel!
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var pm2_5Label: UILabel!
    @IBOutlet weak var airQualityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    private let locationManager:CLLocationManager
    private let presenter:AirQualityPresenterProtocol
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    init(presenter:AirQualityPresenterProtocol, locationManager:CLLocationManager = CLLocationManager()) {
        self.presenter = presenter
        self.locationManager = locationManager
        super.init(nibName: "AirQualityViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Air quality index"
        presenter.getAirQuality()
    }

    func newState(airQualityViewState: AirQualityViewState) {
        switch airQualityViewState.status {
        case .success:
            errorLabel.isHidden = true
            reloadButton.isHidden = true
            activityIndicator.isHidden = true
            no2Label.text = airQualityViewState.airQuality!.no2
            o3Label.text = airQualityViewState.airQuality!.o3
            pm10Label.text = airQualityViewState.airQuality!.pm10
            pm2_5Label.text = airQualityViewState.airQuality!.pm2_5
            airQualityLabel.text = airQualityViewState.airQuality!.aqi
            if let color = UIColor(named: airQualityViewState.airQuality!.aqiColor) {
                airQualityLabel.textColor = color
            }
        case .error:
            errorLabel.isHidden = false
            reloadButton.isHidden = false
            activityIndicator.isHidden = true
            if airQualityViewState.reqPermission {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            }else {
                errorLabel.text = airQualityViewState.error!
            }
        case .loading:
            errorLabel.isHidden = true
            reloadButton.isHidden = true
            activityIndicator.isHidden = false
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        presenter.getAirQuality()
    }
}

extension AirQualityViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            presenter.getAirQuality()
        }
    }
}

