//
//  AirQualityEntity.swift
//  CleanArchitecture
//
//  Created by Alberto on 27/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

class AirQualityEntity {
    
    private let no2Matrix = [(min:0,max:50, value: AQIName.vl), (min:50, max:100, value: AQIName.l), (min:100, max:200, value: AQIName.m), (min:200, max:400, value: AQIName.h), (min:400, max:Int.max, value: AQIName.vh)]
    private let o3Matrix = [(min:0,max:60, value: AQIName.vl), (min:60, max:120, value: AQIName.l), (min:120, max:180, value: AQIName.m), (min:180, max:240, value: AQIName.h), (min:240, max:Int.max, value: AQIName.vh)]
    private let pm10Matrix = [(min:0,max:25, value: AQIName.vl), (min:25, max:50, value: AQIName.l), (min:50, max:90, value: AQIName.m), (min:90, max:180, value: AQIName.h), (min:180, max:Int.max, value: AQIName.vh)]
    private let pm2_5Matrix = [(min:0,max:15, value: AQIName.vl), (min:15, max:30, value: AQIName.l), (min:30, max:55, value: AQIName.m), (min:55, max:110, value: AQIName.h), (min:110, max:Int.max, value: AQIName.vh)]
    

    func process(airQualityDatas: Array<AirQualityData>) -> AirQualityResult {
        let no2 = airQualityDatas.first { $0.type == "no2" }
        let o3 = airQualityDatas.first { $0.type == "o3" }
        let pm10 = airQualityDatas.first { $0.type == "pm10" }
        let pm2_5 = airQualityDatas.first { $0.type == "pm25" }
        let no2AQIName = no2Matrix.first { no2!.measure.value >= Double($0.min) && no2!.measure.value < Double($0.max) }!.value
        let o3AQIName = o3Matrix.first { o3!.measure.value >= Double($0.min) && o3!.measure.value < Double($0.max) }!.value
        let pm10AQIName = pm10Matrix.first { pm10!.measure.value >= Double($0.min) && pm10!.measure.value < Double($0.max) }!.value
        let pm25AQIName = pm2_5Matrix.first { pm2_5!.measure.value >= Double($0.min) && pm2_5!.measure.value < Double($0.max) }!.value
        let aqiName = [no2AQIName, o3AQIName, pm10AQIName, pm25AQIName].sorted { $0.rawValue < $1.rawValue }.last!
        let latitude = (no2!.location.latitude + o3!.location.latitude + pm10!.location.latitude + pm2_5!.location.latitude)/4
        let longitude = (no2!.location.longitude + o3!.location.longitude + pm10!.location.longitude + pm2_5!.location.longitude)/4
        return AirQualityResult(location: Location(latitude: latitude, longitude: longitude), date: Date(), aqi:aqiName, no2:no2!.measure , o3: o3!.measure, pm10: pm10!.measure, pm2_5: pm2_5!.measure)
    }
}
