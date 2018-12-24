//
//  CurrentWeatherJob.swift
//  CleanArchitecture
//
//  Created by Alberto on 22/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

class CurrentWeatherJob {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func weather(location: Location) -> Promise<InstantWeather> {
        let promise = Promise<InstantWeather>()
        if let url = urlForWeather(location: location, apiKey: Constants.openWeatherApiKey) {
            urlSession.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    if response == nil {
                        promise.reject(with: WeatherError.other)
                    } else if let response = response as? HTTPURLResponse, response.statusCode > 299 {
                        promise.reject(with: WeatherError.other)
                    } else if let error = error {
                        switch error.code {
                        case NSURLErrorNotConnectedToInternet:
                            promise.reject(with: WeatherError.noNetwork)
                        case NSURLErrorTimedOut:
                            promise.reject(with: WeatherError.timeout)
                        default:
                            promise.reject(with: WeatherError.other)
                        }
                    }else{
                        let result:CloudResponse? = try? JSONDecoder().decode(CloudResponse.self, from: data!)
                        if result?.cod == 200 {
                            let cr:CloudWeatherResponse? = try? JSONDecoder().decode(CloudWeatherResponse.self, from: data!)
                            if cr != nil {
                                let weather = InstantWeather(name: cr!.name, description: cr!.weather[0].description, icon: cr!.weather[0].icon, temp: cr!.main.temp, pressure: cr!.main.pressure, humidity: cr!.main.humidity, windSpeed: cr!.wind.speed, windDegrees: cr!.wind.deg, datetime: cr!.dt)
                                promise.resolve(with: weather)
                            }else{
                                promise.reject(with: WeatherError.decoding)
                            }
                        }else{
                            if result?.cod == 401{
                                promise.reject(with: WeatherError.unauthorized)
                            }else{
                                promise.reject(with: WeatherError.empty)
                            }
                        }
                    }
                }
            }.resume()
        } else {
            promise.reject(with: WeatherError.other)
        }
        return promise
    }
    
    private func urlForWeather(location: Location, apiKey: String) -> URL? {
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)"
        return URL(string: url)
    }
    
}
