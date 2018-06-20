//
//  WeatherComponent.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class WeatherComponent: NSObject {
    
    static func assemble(apiKey:String, cities:Array<String>) -> WeatherProtocol {
        let url = "https://api.openweathermap.org/data/2.5/weather?q={{city}}&appid=\(apiKey)"
        var workers = Array<Worker>()
        for city in cities {
            let targetUrl = url.replacingOccurrences(of: "{{city}}", with: "\(city)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            workers.append(CurrentWeatherWorker(url: targetUrl))
        }
        return Weather(currentWeatherWorkers: workers)
    }

}
