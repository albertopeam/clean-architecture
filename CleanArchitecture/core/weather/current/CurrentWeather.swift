//
//  Sample.swift
//  CleanArchitecture
//
//  Created by Alberto on 21/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

protocol CurrentWeatherProtocol {
    func current(output: CurrentWeatherOutputProtocol)
}

protocol CurrentWeatherOutputProtocol {
    func weather(weather: InstantWeather)
    func weatherError(error: CurrentWeatherError)
}

public enum CurrentWeatherError: Swift.Error {
    case noLocationPermission
    case noPermissions
    case noLocationEnabled
    case noLocation
    case error
}

public class CurrentWeather: CurrentWeatherProtocol {

    private let locationJob: LocationJob
    private let weatherJob: CurrentWeatherJob
    
    init(locationJob: LocationJob,
         weatherJob: CurrentWeatherJob) {
        self.locationJob = locationJob
        self.weatherJob = weatherJob
    }
    
    func current(output: CurrentWeatherOutputProtocol) {
        locationJob.location().chained { (location) -> Future<InstantWeather> in
            return self.weatherJob.weather(location: location)
        }.observe { (result) in
            switch result {
            case .success(let weather):
                output.weather(weather: weather)
            case .failure(let error):
                if let error = error as? LocationError {
                    switch error {
                    case .noLocationPermission:
                        output.weatherError(error: .noLocationPermission)
                    case .restrictedLocationUsage:
                        output.weatherError(error: .noPermissions)
                    case .noLocationEnabled:
                        output.weatherError(error: .noLocationEnabled)
                    case .deniedLocationUsage:
                        output.weatherError(error: .noPermissions)
                    case .noLocation:
                        output.weatherError(error: .noLocation)
                    }
                } else {
                    output.weatherError(error: .error)
                }
            }
        }
    }
    
}
