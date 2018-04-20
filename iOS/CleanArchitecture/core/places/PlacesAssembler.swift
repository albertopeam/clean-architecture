//
//  PlacesAssembler.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import CoreLocation

class PlacesAssembler {
    static func assemble() -> PlacesProtocol {
        //TODO: cagada lo del location manager, core no debe tener deps de iOS
        let locationGateway = LocationGateway(locationManager: CLLocationManager())
        let placesGateway = PlacesGateway()
        return Places(locationGateway: locationGateway, placesGateway: placesGateway)
    }
}
