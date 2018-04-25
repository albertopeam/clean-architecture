//
//  Places.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

enum LocationError:Error {
    case noLocationPermission, restrictedLocationUsage, noLocationEnabled, deniedLocationUsage, noLocation
}

enum PlacesError:Error {
    case noNetwork, decoding, timeout, noPlaces, badStatus
}

struct Place {
    let id:String
    let placeId:String
    let name:String
    let icon:String
    let openNow:Bool
    let rating:Double
    let location:Location
}

protocol PlacesProtocol {
    func nearby(output:PlacesOutputProtocol)
}

protocol PlacesOutputProtocol {
    func onNearby(places:Array<Place>)
    func onNearbyError(error:Error)
}

class Places:PlacesProtocol {
    
    private let locationGateway:Work
    private let placesGateway:Work
    
    init(locationGateway:Work, placesGateway:Work) {
        self.locationGateway = locationGateway
        self.placesGateway = placesGateway
    }
    
    func nearby(output: PlacesOutputProtocol) {
        Promise(work: locationGateway)
        .then { (location) -> Promise in
            return Promise(work: self.placesGateway, params:location)
        }.finally { (places) in
            output.onNearby(places: places as! Array<Place>)
        }.error { (error) in
            output.onNearbyError(error: error)
        }
    }
}
