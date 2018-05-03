//
//  PlacesAssembler.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

class PlacesComponent {
    static func assemble(apiKey:String) -> PlacesProtocol {
        return Places(locationGateway: LocationGateway(), placesGateway: PlacesGateway(apiKey: apiKey))
    }
}
