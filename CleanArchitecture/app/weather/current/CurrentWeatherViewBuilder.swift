//
//  CurrentWeatherBuilder.swift
//  CleanArchitecture
//
//  Created by Alberto on 22/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit.UIViewController

class CurrentWeatherViewBuilder {
    
    static func build() -> UIViewController {
        let locationJob = LocationJob(noPermissionError: LocationError.noLocationPermission)
        let weatherJob = CurrentWeatherJob(urlSession: URLSession.shared)
        let currentWeather = CurrentWeather(locationJob: locationJob, weatherJob: weatherJob)
        let presenter = CurrentWeatherPresenter(currentWeather: currentWeather)
        let vc = CurrentWeatherViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }
}
