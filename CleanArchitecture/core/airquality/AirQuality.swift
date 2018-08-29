//
//  AirQuality.swift
//  CleanArchitecture
//
//  Created by Alberto on 27/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

class AirQualityComponent {
    static func assemble() -> AirQualityProtocol {
        let url = "https://api.openaq.org/v1/measurements?coordinates={{lat}},{{lon}}&limit=1&parameter={{measure}}&has_geo=true"
        let measurements = ["pm25", "pm10", "no2", "o3"]
        var airQualityWorkers = Array<Worker>()
        for measure in measurements {
            let airQualityWorker = AirQualityWorker(url: url.replacingOccurrences(of: "{{measure}}", with: measure))
            airQualityWorkers.append(airQualityWorker)
        }
        let locationWorker = LocationWorker()
        return AirQuality(locationWorker: locationWorker, airQualityWorkers: airQualityWorkers)
    }
}

struct AirQualityData {
    let location:Location
    let date:String
    let type:String
    let measure:Measure
}

struct AirQualityResult {
    let location:Location
    let date:Date
    let aqi:AQIName
    let no2:Measure
    let o3:Measure
    let pm10:Measure
    let pm2_5:Measure
}

struct Measure {
    let value:Double
    let unit:String
}

enum AQIName:Int {
    case vl, l, m, h, vh
}

enum AirQualityError:Error {
    case noNetwork, decoding, timeout, unauthorized, other
}

protocol AirQualityProtocol {
    func getAirQuality(output:AirQualityOutputProtocol)
}

protocol AirQualityOutputProtocol {
    func onGetAirQuality(airQuality:AirQualityResult)
    func onErrorAirQuality(error:Error)
}


class AirQuality:AirQualityProtocol {
    
    private let locationWorker:LocationWorker
    private let airQualityWorkers:Array<Worker>
    
    init(locationWorker:LocationWorker, airQualityWorkers:Array<Worker>) {
        self.locationWorker = locationWorker
        self.airQualityWorkers = airQualityWorkers
    }
    
    func getAirQuality(output:AirQualityOutputProtocol) {
        async {
            let location = try await(promise: Promises.once(worker: self.locationWorker)) as! Location
            let airQualityDatas:Array<AirQualityData> = try await(promise: Promises.all(workers: self.airQualityWorkers, params: location)) as! Array<AirQualityData>
            let airQualityEntity = AirQualityEntity(airQualityDatas: airQualityDatas)
            return airQualityEntity.process()
        }.success { (airQualityResult) in
            output.onGetAirQuality(airQuality: airQualityResult)
        }.error { (error) in
            output.onErrorAirQuality(error: error)
        }
    }
}
