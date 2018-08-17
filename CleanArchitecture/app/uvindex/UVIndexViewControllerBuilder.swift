//
//  UVIndexViewControllerBuilder.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import UIKit

class UVIndexViewControllerBuilder {
    static func assemble() -> UIViewController {
        let uvIndex = UVIndexComponent.assemble(apiKey: Constants.openWeatherApiKey)
        let viewModel = UVIndexViewModel(uvIndex: uvIndex)
        let controller = UVIndexViewController(viewModel: viewModel)
        return controller
    }
}
