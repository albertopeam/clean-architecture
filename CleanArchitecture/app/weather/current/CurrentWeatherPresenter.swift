//
//  CurrentWeatherPresenter.swift
//  CleanArchitecture
//
//  Created by Alberto on 22/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

protocol CurrentWeatherPresenterProtocol {
    func current()
}

protocol CurrentWeatherViewProtocol: class {
    func show(viewModel: CurrentWeatherViewModel)
    func askLocationPermission()
    func error(message: String)
    func hideLoading()
    func showLoading()
}

class CurrentWeatherPresenter {
    
    private let currentWeather: CurrentWeatherProtocol
    weak var view: CurrentWeatherViewProtocol?
    
    init(currentWeather: CurrentWeatherProtocol) {
        self.currentWeather = currentWeather
    }
    
    func current() {
        view?.showLoading()
        currentWeather.current(output: self)
    }
    
}

extension CurrentWeatherPresenter: CurrentWeatherOutputProtocol {
    
    func weather(weather: InstantWeather) {
        view?.hideLoading()
        let viewModel = CurrentWeatherViewModel(city: weather.name,
                                                description: weather.description,
                                                temperature: "\(weather.temp)k",
                                                pressure: "\(weather.pressure)hPa",
                                                humidity: "\(weather.humidity)%",
                                                windSpeed: "\(weather.windSpeed)m/s")
        view?.show(viewModel: viewModel)
    }
    
    func weatherError(error: CurrentWeatherError) {
        view?.hideLoading()
        switch error {
        case .noLocationPermission:
            view?.askLocationPermission()
        case .noPermissions:
            view?.error(message: "No permissions, please go to settings and give permission")
        case .noLocationEnabled:
            view?.error(message: "No location enabled, please go to settings and enable location")
        case .noLocation:
            view?.error(message: "No location available")
        case .error:
            view?.error(message: "Internal error")
        }
    }
    
}
