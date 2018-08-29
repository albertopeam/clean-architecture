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
        let airQualityEntity = AirQualityEntity()
        return AirQuality(locationWorker: locationWorker, airQualityWorkers: airQualityWorkers, airQualityEntity: airQualityEntity)
    }
}

struct AirQualityData {
    let location:Location
    let date:String
    let type:String
    let measure:Measure
}

struct AirQualityResult:Equatable {
    let location:Location
    let date:Date
    let aqi:AQIName
    let no2:Measure
    let o3:Measure
    let pm10:Measure
    let pm2_5:Measure
    static func == (lhs: AirQualityResult, rhs: AirQualityResult) -> Bool {
        return lhs.location == rhs.location &&
            lhs.date == rhs.date &&
            lhs.aqi == rhs.aqi &&
            lhs.no2 == rhs.no2 &&
            lhs.o3 == rhs.o3 &&
            lhs.pm10 == rhs.pm10 &&
            lhs.pm2_5 == rhs.pm2_5;
    }
}

struct Measure {
    let value:Double
    let unit:String
    static func == (lhs: Measure, rhs: Measure) -> Bool {
        return lhs.value == rhs.value && lhs.unit == rhs.unit
    }
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
    
    private let locationWorker:Worker
    private let airQualityWorkers:Array<Worker>
    private let airQualityEntity:AirQualityEntity
    
    init(locationWorker:Worker, airQualityWorkers:Array<Worker>, airQualityEntity:AirQualityEntity) {
        self.locationWorker = locationWorker
        self.airQualityWorkers = airQualityWorkers
        self.airQualityEntity = airQualityEntity
    }
    
    func getAirQuality(output:AirQualityOutputProtocol) {
        async {
            let location = try await(promise: Promises.once(worker: self.locationWorker)) as! Location
            let airQualityDatas:Array<AirQualityData> = try await(promise: Promises.all(workers: self.airQualityWorkers, params: location)) as! Array<AirQualityData>
            return self.airQualityEntity.process(airQualityDatas: airQualityDatas)
        }.success { (airQualityResult) in
            output.onGetAirQuality(airQuality: airQualityResult)
        }.error { (error) in
            output.onErrorAirQuality(error: error)
        }
    }
}
