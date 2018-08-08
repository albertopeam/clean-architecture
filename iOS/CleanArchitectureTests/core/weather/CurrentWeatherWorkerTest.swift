//
//  CurrentWeatherWorkerTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class CurrentWeatherWorkerTest: NetworkTestCase {
    
    private var sut:CurrentWeatherWorker?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGivenSuccessEnvWhenGetWeatherThenMatchResult() throws {
        let expectation = XCTestExpectation(description: "testGivenSuccessEnvWhenGetWeatherThenMatchResult")
        let absoluteUrl = "\(serverUrl())weather?q=TestCity&appid=TestApiKey"
        dispatchResponseToGetRequest(url: absoluteUrl, fileName: "current-weather-success")
        sut = CurrentWeatherWorker(url: absoluteUrl)
        try sut!.run(params: nil, resolve: { (worker, result) in
            XCTAssertNotNil(result)
            let weather = result as! InstantWeather
            XCTAssertEqual(weather.name, "London")
            XCTAssertEqual(weather.description, "light intensity drizzle")
            XCTAssertEqual(weather.datetime, 1485789600)
            XCTAssertEqual(weather.humidity, 81.0)
            XCTAssertEqual(weather.icon, "09d")
            XCTAssertEqual(weather.pressure, 1012.1)
            XCTAssertEqual(weather.temp, 280.32)
            XCTAssertEqual(weather.windDegrees, 80)
            XCTAssertEqual(weather.windSpeed, 4.1)
            expectation.fulfill()
        }) { (worker, error) in
            XCTFail("testGivenSuccessEnvWhenGetWeatherThenMatchResult rejected")
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGivenErrorEnvWhenGetWeatherThenMatchError() throws {
        let expectation = XCTestExpectation(description: "testGivenErrorEnvWhenGetWeatherThenMatchError")
        let absoluteUrl = "\(serverUrl())weather?q=TestCity&appid=TestApiKey"
        dispatchErrorResponseToGetRequest(statusCode: 400, status: "Bad Request", url: absoluteUrl)
        sut = CurrentWeatherWorker(url: absoluteUrl)
        try sut!.run(params: nil, resolve: { (worker, result) in
            XCTFail("testGivenErrorEnvWhenGetWeatherThenMatchError rejected")
        }) { (worker, error) in
            XCTAssertNotNil(error)
            XCTAssertEqual(error.code, WeatherError.other.code)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
