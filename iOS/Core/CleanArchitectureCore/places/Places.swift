//
//  Places.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

public enum LocationError:Error, Equatable {
    case noLocationPermission, restrictedLocationUsage, noLocationEnabled, deniedLocationUsage, noLocation
}

public enum PlacesError:Error {
    case noNetwork, decoding, timeout, noPlaces, badStatus
}

public struct Place {
    public let id:String
    public let placeId:String
    public let name:String
    public let icon:String
    public let openNow:Bool
    public let rating:Double
    public let location:Location
}

public struct Location {
    public let latitude:Double
    public let longitude:Double
}


public protocol PlacesProtocol {
    func nearby(output:PlacesOutputProtocol)
}

public protocol PlacesOutputProtocol {
    func onNearby(places:Array<Place>)
    func onNearbyError(error:Error)
}

internal class Places:PlacesProtocol {
    
    private let locationGateway:Worker
    private let placesGateway:Worker
    
    init(locationGateway:Worker, placesGateway:Worker) {
        self.locationGateway = locationGateway
        self.placesGateway = placesGateway
    }
    
    func nearby(output: PlacesOutputProtocol) {
        Promise(work: locationGateway)
        .then { (location) -> Promise in
            return Promise(work: self.placesGateway, params:location)
        }.then { (places) in
            output.onNearby(places: places as! Array<Place>)
        }.error { (error) in
            output.onNearbyError(error: error)
        }
    }
}
