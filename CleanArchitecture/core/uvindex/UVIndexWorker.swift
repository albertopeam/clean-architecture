//
//  UVIndexGateway.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

class UVIndexWorker: Worker {
    
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
                let response = JsonDecoder<CloudUltravioletIndex>.decode(data: data!)
                if let response = response {
                    let result = UltravioletIndex(location: Location(latitude: response.lat, longitude: response.lon), date: response.date, timestamp: response.timestamp, uvIndex: response.uvIndex)
                    self.resolveIt(resolve: resolve, data: result)
                }else{
                    self.rejectIt(reject: reject, error: UVIndexError.decoding)
                }
            }
        }.resume()
    }
}

private struct CloudUltravioletIndex:Codable{
    let lat:Double
    let lon:Double
    let date:String
    let timestamp:Int
    let uvIndex:Double
    enum CodingKeys: String, CodingKey {
        case lat; case lon; case date = "date_iso"; case timestamp = "date"; case uvIndex = "value"
    }
}
