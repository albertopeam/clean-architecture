//
//  UVIndexComponent.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

class UVIndexComponent {
    static func assemble(apiKey:String) -> UVIndexProtocol {
        return UVIndex(locationWorker: LocationWorker(), uvIndexWorker: UVIndexWorker(apiKey: apiKey))
    }
}
