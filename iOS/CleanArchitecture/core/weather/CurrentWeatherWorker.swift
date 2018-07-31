//
//  CurrentWeatherWorker.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

class CurrentWeatherWorker:NSObject, Worker {
    
    let targetUrl:String
    
    init(url:String) {
        self.targetUrl = url
    }
    
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        let url = URL(string: targetUrl)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.rejectIt(reject: reject, error: error!)
            }else{
                let result:CloudResponse? = try? JSONDecoder().decode(CloudResponse.self, from: data!)
                if result?.cod == 200 {
                    let cr:CloudWeatherResponse? = try? JSONDecoder().decode(CloudWeatherResponse.self, from: data!)
                    if cr != nil {
                        let weather = InstantWeather(name: cr!.name, description: cr!.weather[0].description, icon: cr!.weather[0].icon, temp: cr!.main.temp, pressure: 0/*cr!.main.pressure*/, humidity: cr!.main.humidity, windSpeed: cr!.wind.speed, windDegrees: cr!.wind.deg, datetime: cr!.dt)
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
    
    
    private func rejectIt(reject: @escaping RejectableWorker, error:Error) {
        DispatchQueue.main.sync {
            reject(self, error)
        }
    }
    
    private func resolveIt(resolve: @escaping ResolvableWorker, data:Any) {
        DispatchQueue.main.sync {
            resolve(self, data)
        }
    }
    
}

struct CloudResponse:Codable  {
    var cod:Int
}

fileprivate struct CloudWeatherResponse:Codable  {
    fileprivate var cod:Int
    fileprivate var name:String
    fileprivate var dt:Int
    fileprivate var weather:Array<CloudWeather>
    fileprivate var main:CloudMain
    fileprivate var wind:CloudWind
    fileprivate struct CloudWeather:Codable  {
        fileprivate var description:String
        fileprivate var icon:String
    }
    fileprivate struct CloudMain:Codable{
        fileprivate var temp:Double
        fileprivate var pressure:Double
        fileprivate var humidity:Double
    }
    fileprivate struct CloudWind:Codable{
        fileprivate var speed:Double
        fileprivate var deg:Double
    }
}
