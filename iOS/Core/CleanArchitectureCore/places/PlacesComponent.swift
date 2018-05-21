//
//  PlacesAssembler.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

public class PlacesComponent {
    public static func assemble(apiKey:String) -> PlacesProtocol {
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&radius=150&types=restaurant&location={{location}}"
        return Places(locationGateway: LocationGateway(), placesGateway: PlacesGateway(url: url))
    }
}
