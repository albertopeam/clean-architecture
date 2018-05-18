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
    var error:String?
    var requestPermission:Bool
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
        viewModel.error = nil
        viewModel.requestPermission = false
        viewModel.places = places
        view?.newState(viewModel: viewModel)
    }
    
    func onNearbyError(error: Error) {
        viewModel.requestPermission = false
        viewModel.error = nil
        switch error{
            case LocationError.noLocationPermission:
                viewModel.requestPermission = true
                break
            case LocationError.deniedLocationUsage:
                viewModel.error = "Denied location usage"
                break
            case LocationError.restrictedLocationUsage:
                viewModel.error = "Restricted location usage"
                break
            case LocationError.noLocationEnabled:
                viewModel.error = "No location enabled"
                break
            case LocationError.noLocation:
                viewModel.error = "No location available"
                break
            case PlacesError.noNetwork:
                viewModel.error = "No network"
                break
            case PlacesError.decoding:
                viewModel.error = "Internal error"
                break
            case PlacesError.timeout:
                viewModel.error = "Try again, timeout"
                break
            case PlacesError.noPlaces:
                viewModel.error = "No results"
                break
            case PlacesError.badStatus:
                viewModel.error = "Interal problem, Google API request denied"
                break
        default:
            break
        }
        view?.newState(viewModel: viewModel)
    }
}
