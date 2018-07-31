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
    var loading:Bool
    var weathers:Array<InstantWeather>?
    var error:String?
}

class WeatherPresenter: WeatherPresenterProtocol, WeatherOutputProtocol {
    
    private let weather:WeatherProtocol
    private var viewModel:WeatherViewModel
    var view:WeatherViewProtocol?
    
    init(weather:WeatherProtocol, viewModel:WeatherViewModel, view:WeatherViewProtocol? = nil) {
        self.weather = weather
        self.viewModel = viewModel
        self.view = view
    }
    
    func weathers() {
        weather.current(output: self)
    }
    
    func onWeather(items: Array<InstantWeather>) {
        viewModel.loading = false
        viewModel.weathers = items
        viewModel.error = nil
        view?.newState(viewModel: viewModel)
    }
    
    func onWeatherError(error: Error) {
        viewModel.loading = false
        viewModel.weathers = nil
        viewModel.error = error.domain
        view?.newState(viewModel: viewModel)
    }

}
