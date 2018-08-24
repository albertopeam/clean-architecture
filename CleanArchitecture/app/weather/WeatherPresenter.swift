//
//  WeatherPresenter.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 25/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

protocol WeatherViewProtocol {
    func newState(viewState:WeatherViewState)
}

protocol WeatherPresenterProtocol {
    func weathers()
}

struct WeatherViewState {
    var loading:Bool
    var weathers:Array<InstantWeather>?
    var error:String?
}

class WeatherPresenter: WeatherPresenterProtocol, WeatherOutputProtocol {
    
    private let weather:WeatherProtocol
    private var viewState:WeatherViewState
    var view:WeatherViewProtocol?
    
    init(weather:WeatherProtocol, viewState:WeatherViewState, view:WeatherViewProtocol? = nil) {
        self.weather = weather
        self.viewState = viewState
        self.view = view
    }
    
    func weathers() {
        weather.current(output: self)
    }
    
    func onWeather(items: Array<InstantWeather>) {
        viewState.loading = false
        viewState.weathers = items
        viewState.error = nil
        view?.newState(viewState: viewState)
    }
    
    func onWeatherError(error: Error) {
        viewState.loading = false
        viewState.weathers = nil
        viewState.error = error.domain
        view?.newState(viewState: viewState)
    }

}
