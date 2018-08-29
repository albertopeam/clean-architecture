//
//  AirQualityEntity.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 29/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class AirQualityEntityTest: XCTestCase {
    
    private var sut:AirQualityEntity?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGivenAirQualityDataWhenProcessThenMatchData() {
        let location = Location(latitude: 43, longitude: -8)
        let unit = "μg/m3"
        let value = 1.0
        let no2 = AirQualityData(location: location, date: "now", type: "no2", measure: Measure(value: value, unit: unit))
        let o3 = AirQualityData(location: location, date: "now", type: "o3", measure: Measure(value: 120.0, unit: unit))
        let pm10 = AirQualityData(location: location, date: "now", type: "pm10", measure: Measure(value: value, unit: unit))
        let pm2_5 = AirQualityData(location: location, date: "now", type: "pm25", measure: Measure(value: value, unit: unit))
        let airQualityDatas = [no2, o3, pm10, pm2_5]
        sut = AirQualityEntity()
        let airQualityResult = sut?.process(airQualityDatas: airQualityDatas)
        XCTAssertEqual(airQualityResult!.location.latitude, location.latitude)
        XCTAssertEqual(airQualityResult!.location.longitude, location.longitude)
        XCTAssertEqual(airQualityResult!.aqi, AQIName.m)
    }
    
}
