//
//  CurrentWeatherWorker.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

class CurrentWeatherWorker:NSObject, Worker {
    
    private let targetUrl: String
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared,
         url: String) {
        self.urlSession = urlSession
        self.targetUrl = url
    }
    
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        let url = URL(string: targetUrl)
        urlSession.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                switch error!.code {
                case NSURLErrorNotConnectedToInternet:
                    self.rejectIt(reject: reject, error: WeatherError.noNetwork)
                    break
                case NSURLErrorTimedOut:
                    self.rejectIt(reject: reject, error: WeatherError.timeout)
                    break
                default:
                    self.rejectIt(reject: reject, error: WeatherError.other)
                }
            } else if response == nil || (response as! HTTPURLResponse).statusCode > 299 {
                self.rejectIt(reject: reject, error: WeatherError.other)                
            } else{
                let result:CloudResponse? = try? JSONDecoder().decode(CloudResponse.self, from: data!)
                if result?.cod == 200 {
                    let cr:CloudWeatherResponse? = try? JSONDecoder().decode(CloudWeatherResponse.self, from: data!)
                    if cr != nil {
                        let weather = InstantWeather(name: cr!.name, description: cr!.weather[0].description, icon: cr!.weather[0].icon, temp: cr!.main.temp, pressure: cr!.main.pressure, humidity: cr!.main.humidity, windSpeed: cr!.wind.speed, windDegrees: cr!.wind.deg, datetime: cr!.dt)
                        self.resolveIt(resolve: resolve, data: weather)
                    }else{
                        self.rejectIt(reject: reject, error: WeatherError.decoding)
                    }
                }else{
                    if result?.cod == 401{
                        self.rejectIt(reject: reject, error: WeatherError.unauthorized)
                    }else{
                        self.rejectIt(reject: reject, error: WeatherError.empty)
                    }
                }
            }
        }.resume()
    }
}

struct CloudResponse:Codable  {
    var cod:Int
}

struct CloudWeatherResponse:Codable  {
    var cod:Int
    var name:String
    var dt:Int
    var weather:Array<CloudWeather>
    var main:CloudMain
    var wind:CloudWind
    struct CloudWeather:Codable  {
        var description:String
        var icon:String
    }
    struct CloudMain:Codable{
        var temp:Double
        var pressure:Double
        var humidity:Double
    }
    struct CloudWind:Codable{
        var speed:Double
        var deg:Double
    }
}
