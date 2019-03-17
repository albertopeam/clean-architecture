//
//  AirQualityTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 29/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class AirQualityTest: XCTestCase {
    
    private var spy: Spy.AirQualityOutput!
    private var sut: AirQuality!
    
    override func tearDown() {
        sut = nil
        spy = nil
        super.tearDown()
    }
    
    func testGivenSuccesfullyEnvironmentWhenGetAirQualityThenMatchResult() {
        spy = Spy.AirQualityOutput(expectation: XCTestExpectation(description: "testGivenSuccesfullyEnvironmentWhenGetAirQualityThenMatchResult"))
        let mockLocation = Location(latitude: 43, longitude: -8)
        let mockNO2Measure = Measure(value: 1.0, unit: "μg/m3")
        let mockO3Measure = mockNO2Measure
        let mockPM10Measure = mockNO2Measure
        let mockPM2_5Measure = mockNO2Measure
        let mockNO2 = AirQualityData(location: mockLocation, date: "now", type: "no2", measure: mockNO2Measure)
        let mockO3 = AirQualityData(location: mockLocation, date: "now", type: "o3", measure: mockO3Measure)
        let mockPM10 = AirQualityData(location: mockLocation, date: "now", type: "pm10", measure: mockPM10Measure)
        let mockPM25 = AirQualityData(location: mockLocation, date: "now", type: "pm25", measure: mockPM2_5Measure)
        let result = AirQualityResult(location: mockLocation, date: Date(), aqi: .vl, no2: mockNO2Measure, o3: mockO3Measure, pm10: mockPM10Measure, pm2_5: mockPM2_5Measure)
        sut = AirQuality(locationWorker: MockLocation.Success(location: mockLocation), airQualityWorkers: [MockWorkers.SuccessWithValue(value: mockNO2), MockWorkers.SuccessWithValue(value: mockO3), MockWorkers.SuccessWithValue(value: mockPM10), MockWorkers.SuccessWithValue(value: mockPM25)], airQualityEntity: MockAirQualityEntity(result: result))
        sut!.getAirQuality(output: spy!)
        wait(for: [spy!.expectation], timeout: TestConstants.timeout)
        XCTAssertNotNil(spy!.airQualityResult)
        XCTAssertEqual(spy!.airQualityResult!, result)
    }
    
    func testGivenErrorEnvironmentWhenGetAirQualityThenMatchError() {
        let mockError:Error = LocationError.noLocation
        spy = Spy.AirQualityOutput(expectation: XCTestExpectation(description: "testGivenErrorEnvironmentWhenGetAirQualityThenMatchError"))
        sut = AirQuality(locationWorker: MockLocation.Err(error: mockError), airQualityWorkers: [], airQualityEntity: MockAirQualityEntity(result: nil))
        sut!.getAirQuality(output: spy!)
        wait(for: [spy!.expectation], timeout: TestConstants.timeout)
        XCTAssertNil(spy!.airQualityResult)
        XCTAssertNotNil(spy!.error)
        XCTAssertEqual(spy!.error!.code,  mockError.code)
    }
}

private class Spy {
    internal class AirQualityOutput:MockExpectation, AirQualityOutputProtocol {
        
        var airQualityResult:AirQualityResult?
        var error:Error?
        
        func onGetAirQuality(airQuality: AirQualityResult) {
            self.airQualityResult = airQuality
            expectation.fulfill()
        }
        
        func onErrorAirQuality(error: Error) {
            self.error = error
            expectation.fulfill()
        }
    }
}

private class MockAirQualityEntity:AirQualityEntity {
    let result:AirQualityResult?
    init(result:AirQualityResult?) {
        self.result = result
    }
    override func process(airQualityDatas: Array<AirQualityData>) -> AirQualityResult {
        return result!
    }
}



