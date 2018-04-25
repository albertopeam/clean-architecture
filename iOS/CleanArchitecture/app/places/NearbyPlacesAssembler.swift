//
//  NearbyPlacesAssembler.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class NearbyPlacesAssembler {
    static func assemble() -> UIViewController {
        let viewModel = NearbyPlacesViewModel()
        let places = PlacesAssembler.assemble(locationManager: LocationManagerBridge(), apiKey: Constants.googleApiKey)
        let presenter = NearbyPlacesPresenter(places: places, viewModel: viewModel)
        let controller = NearbyPlacesViewController(presenter: presenter)
        presenter.view = controller
        return controller
    }
}
