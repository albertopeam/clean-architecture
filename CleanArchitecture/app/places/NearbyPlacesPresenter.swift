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

protocol NearbyPlacesViewProtocol {
    func newState(viewState:NearbyPlacesViewState)
}

struct NearbyPlacesViewState {
    var places:Array<Place>?
    var error:String?
    var requestPermission:Bool
}

class NearbyPlacesPresenter:NearbyPlacesPresenterProtocol, PlacesOutputProtocol {
    
    let places:PlacesProtocol
    var viewState:NearbyPlacesViewState
    var view:NearbyPlacesViewProtocol?
    
    init(places:PlacesProtocol, viewModel:NearbyPlacesViewState, view:NearbyPlacesViewProtocol? = nil) {
        self.places = places
        self.viewState = viewModel
        self.view = view
    }
    
    func nearbyPlaces() {
        places.nearby(output: self)
    }
    
    func onNearby(places: Array<Place>) {
        viewState.error = nil
        viewState.requestPermission = false
        viewState.places = places
        view?.newState(viewState: viewState)
    }
    
    func onNearbyError(error: Error) {
        viewState.requestPermission = false
        viewState.error = nil
        switch error{
            case LocationError.noLocationPermission:
                viewState.requestPermission = true
                break
            case LocationError.deniedLocationUsage:
                viewState.error = "Denied location usage"
                break
            case LocationError.restrictedLocationUsage:
                viewState.error = "Restricted location usage"
                break
            case LocationError.noLocationEnabled:
                viewState.error = "No location enabled"
                break
            case LocationError.noLocation:
                viewState.error = "No location available"
                break
            case PlacesError.noNetwork:
                viewState.error = "No network"
                break
            case PlacesError.decoding:
                viewState.error = "Internal error"
                break
            case PlacesError.timeout:
                viewState.error = "Try again, timeout"
                break
            case PlacesError.noPlaces:
                viewState.error = "No results"
                break
            case PlacesError.badStatus:
                viewState.error = "Interal problem, Google API request denied"
                break
        default:
            break
        }
        view?.newState(viewState: viewState)
    }
}
