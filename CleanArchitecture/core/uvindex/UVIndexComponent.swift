//
//  UVIndexComponent.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

class UVIndexComponent {
    static func assemble(apiKey:String) -> UVIndexProtocol {
        let url = "https://api.openweathermap.org/data/2.5/uvi?lat={{lat}}&lon={{lon}}&appid=\(apiKey)"
        return UVIndex(locationWorker: LocationWorker(), uvIndexWorker: UVIndexWorker(url: url))
    }
}
