//
//  AirQualityViewControllerBuilder.swift
//  CleanArchitecture
//
//  Created by Alberto on 27/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import UIKit

class AirQualityViewControllerBuilder {
    static func assemble() -> UIViewController {
        let airQuality = AirQualityComponent.assemble()
        let presenter = AirQualityPresenter(airQuality: airQuality, airQualityState: AirQualityViewState(status: .loading, airQuality: nil, error: nil, reqPermission: false))
        let vc = AirQualityViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }
}
