//
//  CurrentWeatherBuilder.swift
//  CleanArchitecture
//
//  Created by Alberto on 22/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit.UIViewController

class CurrentWeatherViewBuilder {
    
    private var weatherJob: CurrentWeatherJob = CurrentWeatherJob(urlSession: URLSession.shared)
    private var locationJob: LocationJob = LocationJob()
    private lazy var currentWeather: CurrentWeatherProtocol = CurrentWeather(locationJob: locationJob,
                                                                             weatherJob: weatherJob)
    
    func withLocationJob(locationJob: LocationJob) -> CurrentWeatherViewBuilder {
        self.locationJob = locationJob
        return self
    }
    
    func withWeatherJob(weatherJob: CurrentWeatherJob) -> CurrentWeatherViewBuilder {
        self.weatherJob = weatherJob
        return self
    }
    
    func withCurrentWeather(currentWeather: CurrentWeatherProtocol) -> CurrentWeatherViewBuilder {
        self.currentWeather = currentWeather
        return self
    }
    
    func build() -> UIViewController {
        let presenter = CurrentWeatherPresenter(currentWeather: currentWeather)
        let vc = CurrentWeatherViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }
}
