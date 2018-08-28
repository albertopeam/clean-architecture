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
    let loading:Bool
    let weathers:Array<InstantWeather>?
    let error:String?
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
        view?.newState(viewState: WeatherViewState(loading: false, weathers: items, error: nil))
    }
    
    func onWeatherError(error: Error) {
        view?.newState(viewState: WeatherViewState(loading: false, weathers: nil, error: error.domain))
    }

}
