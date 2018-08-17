//
//  Weather.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

class Weather:WeatherProtocol {
    
    private let currentWeatherWorkers:Array<Worker>
    
    init(currentWeatherWorkers:Array<Worker>) {
        self.currentWeatherWorkers = currentWeatherWorkers
    }
    
    func current(output: WeatherOutputProtocol) {
        Promises.all(workers:currentWeatherWorkers)
        .then(finalizable: { (items) in
            output.onWeather(items: items as! Array<InstantWeather>)
        }).error(rejectable: { (error) in
            output.onWeatherError(error: error)
        })
    }
}

enum WeatherError:Error, Equatable {
    case noNetwork, decoding, timeout, empty, unauthorized, other
}

protocol WeatherProtocol {
    func current(output:WeatherOutputProtocol)
}

protocol WeatherOutputProtocol {
    func onWeather(items:Array<InstantWeather>)
    func onWeatherError(error:Error)
}

struct InstantWeather {
    let name:String
    let description:String
    let icon:String
    let temp:Double
    let pressure:Double
    let humidity:Double
    let windSpeed:Double
    let windDegrees:Double
    let datetime:Int
}
