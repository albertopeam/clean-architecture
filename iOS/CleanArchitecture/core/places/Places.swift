//
//  Places.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

enum LocationError:Error, Equatable {
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

struct Location {
    let latitude:Double
    let longitude:Double
}


protocol PlacesProtocol {
    func nearby(output:PlacesOutputProtocol)
}

protocol PlacesOutputProtocol {
    func onNearby(places:Array<Place>)
    func onNearbyError(error:Error)
}

class Places:PlacesProtocol {

    private let locationGateway:Worker
    private let placesGateway:Worker
    
    init(locationGateway:Worker, placesGateway:Worker) {
        self.locationGateway = locationGateway
        self.placesGateway = placesGateway
    }
    
    //TODO: old promise
//    func nearby(output: PlacesOutputProtocol) {
//        Promise(work: locationGateway)
//        .then { (location) -> Promise in
//            return Promise(work: self.placesGateway, params:location)
//        }.then { (places) in
//            output.onNearby(places: places as! Array<Place>)
//        }.error { (error) in
//            output.onNearbyError(error: error)
//        }
//    }
    
    func nearby(output: PlacesOutputProtocol) {
        Promises.once(worker: locationGateway, params: nil)
        .then(completable: { (location) -> PromiseProtocol in
            return Promises.once(worker: self.placesGateway, params:location)
        }).then(finalizable: { (places) in
            output.onNearby(places: places as! Array<Place>)
        }).error(rejectable: { (error) in
            output.onNearbyError(error: error)
        })
    }
}
