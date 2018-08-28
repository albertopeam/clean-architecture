//
//  AirQualityWorker.swift
//  CleanArchitecture
//
//  Created by Alberto on 27/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

class AirQualityWorker: Worker {
    
    var url:String
    
    init(url:String) {
        self.url = url
    }
    
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        let location:Location = params as! Location
        self.url = url.replacingOccurrences(of: "{{lat}}", with: "\(location.latitude)")
        self.url = url.replacingOccurrences(of: "{{lon}}", with: "\(location.longitude)")
        let targetUrl = URL(string: self.url)
        URLSession.shared.dataTask(with: targetUrl!) { (data, response, error) in
            if response == nil || (response as! HTTPURLResponse).statusCode > 299 {
                self.rejectIt(reject: reject, error: UVIndexError.other)
            } else if error != nil {
                switch error!.code {
                case NSURLErrorNotConnectedToInternet:
                    self.rejectIt(reject: reject, error: UVIndexError.noNetwork)
                    break
                case NSURLErrorTimedOut:
                    self.rejectIt(reject: reject, error: UVIndexError.timeout)
                    break
                default:
                    self.rejectIt(reject: reject, error: UVIndexError.other)
                }
            } else {
                let response = JsonDecoder<Welcome>.decode(data: data!)
                if let response = response {
                    let airQualityDatas =  response.results.map({ (result) -> AirQualityData in
                        return AirQualityData(location: Location(latitude: result.coordinates.latitude, longitude: result.coordinates.longitude), date: result.date.utc, type: result.parameter, measure: Measure(value: result.value, unit: result.unit))
                    })
                    self.resolveIt(resolve: resolve, data: airQualityDatas.first!)
                }else{
                    self.rejectIt(reject: reject, error: UVIndexError.decoding)
                }
            }
            }.resume()
    }
}

private struct Welcome: Codable {
    let meta: Meta
    let results: [Result]
}

private struct Meta: Codable {
    let name, license, website: String
    let page, limit, found: Int
}

private struct Result: Codable {
    let location, parameter: String
    let date: DateClass
    let value: Double
    let unit: String
    let coordinates: Coordinates
    let country, city: String
}

private struct Coordinates: Codable {
    let latitude, longitude: Double
}

private struct DateClass: Codable {
    let utc: String
    let local: String
}

