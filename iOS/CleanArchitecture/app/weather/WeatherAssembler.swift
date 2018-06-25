//
//  WeatherAssembler.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 25/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import UIKit

class WeatherAssembler {
    static func assemble() -> UIViewController {
        let viewModel = WeatherViewModel(weathers: nil, error: nil)
        let weather = WeatherComponent.assemble(apiKey: Constants.openWeatherApiKey, cities: ["A Coruña", "Lugo", "Ourense", "Pontevedra"])
        let presenter = WeatherPresenter(weather: weather, viewModel: viewModel)
        let controller = WeatherViewController(presenter: presenter)
        presenter.view = controller
        return controller
    }
}
