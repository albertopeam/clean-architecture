//
//  Places.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

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

    private let locationWorker:Worker
    private let placesGateway:Worker
    
    init(locationWorker:Worker, placesGateway:Worker) {
        self.locationWorker = locationWorker
        self.placesGateway = placesGateway
    }
    
    func nearby(output: PlacesOutputProtocol) {
        Promises.once(worker: locationWorker, params: nil)
        .then(completable: { (location) -> PromiseProtocol in
            return Promises.once(worker: self.placesGateway, params:location)
        }).then(finalizable: { (places) in
            output.onNearby(places: places as! Array<Place>)
        }).error(rejectable: { (error) in
            output.onNearbyError(error: error)
        })
    }
}
