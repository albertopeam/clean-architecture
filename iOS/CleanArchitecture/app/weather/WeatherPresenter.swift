//
//  WeatherPresenter.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 25/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

protocol WeatherViewProtocol {
    func newState(viewModel:WeatherViewModel)
}

protocol WeatherPresenterProtocol {
    func weathers()
}

struct WeatherViewModel {
    var weathers:Array<InstantWeather>?
    var error:String?
}

class WeatherPresenter: WeatherPresenterProtocol, WeatherOutputProtocol {
    
    let weather:WeatherProtocol
    var viewModel:WeatherViewModel
    var view:WeatherViewProtocol?
    
    init(weather:WeatherProtocol, viewModel:WeatherViewModel) {
        self.weather = weather
        self.viewModel = viewModel
    }
    
    func weathers() {
        weather.current(output: self)
    }
    
    func onWeather(items: Array<InstantWeather>) {
        viewModel.weathers = items
        viewModel.error = nil
        view?.newState(viewModel: viewModel)
    }
    
    func onWeatherError(error: Error) {
        viewModel.weathers = nil
        viewModel.error = error.localizedDescription
        view?.newState(viewModel: viewModel)
    }

}
