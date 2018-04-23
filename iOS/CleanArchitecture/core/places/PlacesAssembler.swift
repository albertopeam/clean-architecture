//
//  PlacesAssembler.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import CoreLocation

class PlacesAssembler {
    static func assemble(locationManager:LocationManagerProtocol) -> PlacesProtocol {
        let locationGateway = LocationGateway(locationManager: locationManager)
        let placesGateway = PlacesGateway()
        return Places(locationGateway: locationGateway, placesGateway: placesGateway)
    }
}
