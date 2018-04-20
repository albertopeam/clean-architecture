//
//  NearbyPlacesPresenter.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

protocol NearbyPlacesPresenterProtocol {
    func nearbyPlaces()
}

protocol NearbyPlacesView {
    func newState(viewModel:NearbyPlacesViewModel)
}

struct NearbyPlacesViewModel {
    var places:Array<Place>?
    var error:Error?
}

class NearbyPlacesPresenter:NearbyPlacesPresenterProtocol, PlacesOutputProtocol {
    
    let places:PlacesProtocol
    var viewModel:NearbyPlacesViewModel
    var view:NearbyPlacesView?
    
    init(places:PlacesProtocol, viewModel:NearbyPlacesViewModel) {
        self.places = places
        self.viewModel = viewModel
    }
    
    func nearbyPlaces() {
        places.nearby(output: self)
    }
    
    func onNearby(places: Array<Place>) {
        //TODO: modify according results
        viewModel.error = nil
        viewModel.places = places
        view?.newState(viewModel: viewModel)
    }
    
    func onNearbyError(error: Error) {
        //TODO: modify according error
        viewModel.error = error
        view?.newState(viewModel: viewModel)
    }
}
