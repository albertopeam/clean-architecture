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
        let viewModel = NearbyPlacesViewModel(places: nil, error: nil, requestPermission: false)
        let places = PlacesComponent.assemble(apiKey: Constants.googleApiKey)
        let presenter = NearbyPlacesPresenter(places: places, viewModel: viewModel)
        let controller = NearbyPlacesViewController(presenter: presenter)
        presenter.view = controller
        return controller
    }
}
