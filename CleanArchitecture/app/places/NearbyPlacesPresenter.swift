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
    let places:Array<Place>?
    let error:String?
    let requestPermission:Bool
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
        view?.newState(viewState: NearbyPlacesViewState(places: places, error: nil, requestPermission: false))
    }
    
    func onNearbyError(error: Error) {
        let parsedError = parseError(error: error)
        view?.newState(viewState: NearbyPlacesViewState(places: nil, error: parsedError.error, requestPermission: parsedError.reqPermission))
    }
    
    func parseError(error:Error) -> (reqPermission:Bool, error:String?) {
        switch error{
        case LocationError.noLocationPermission:
            return (true, nil)
        case LocationError.deniedLocationUsage:
            return (false, "Denied location usage")
        case LocationError.restrictedLocationUsage:
            return (false, "Restricted location usage")
        case LocationError.noLocationEnabled:
            return (false, "No location enabled")
        case LocationError.noLocation:
            return (false, "No location available")
        case PlacesError.noNetwork:
            return (false, "No network")
        case PlacesError.decoding:
            return (false, "Internal error")
        case PlacesError.timeout:
            return (false, "Try again, timeout")
        case PlacesError.noPlaces:
            return (false, "No results")
        case PlacesError.badStatus:
            return (false, "Interal problem, Google API request denied")
        default:
            return (false, "Unkown error")
        }
    }
}
