//
//  WeatherTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class WeatherTest: XCTestCase {
    
    private var sut:Weather?
    private var spy:SpyWeather?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGivenSuccessWorkerWhenGetWeatherThenMatchResult() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkerWhenGetWeatherThenMatchResult")
        let weather = InstantWeather(name: "name", description: "description", icon: "icon", temp: 25.5, pressure: 1024, humidity: 75.5, windSpeed: 2.2, windDegrees: 3.3, datetime: 1)
        let worker = MockWeather.Success(weather: weather)
        spy = SpyWeather(expectation: expectation)
        sut = Weather(currentWeatherWorkers: [worker])
        sut!.current(output: spy!)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(spy!.items?.count, 1)
        let target:InstantWeather = spy!.items![0]
        XCTAssertEqual(target.name, weather.name)
        XCTAssertEqual(target.description, weather.description)
        XCTAssertEqual(target.icon, weather.icon)
        XCTAssertEqual(target.temp, weather.temp)
        XCTAssertEqual(target.pressure, weather.pressure)
        XCTAssertEqual(target.humidity, weather.humidity)
        XCTAssertEqual(target.windSpeed, weather.windSpeed)
        XCTAssertEqual(target.windDegrees, weather.windDegrees)
        XCTAssertEqual(target.datetime, weather.datetime)
    }
    
    func testGivenNotSuccessWorkerWhenGetWeatherThenMatchError() {
        let expectation = XCTestExpectation(description: "testGivenNotSuccessWorkerWhenGetWeatherThenMatchError")
        let worker = MockWeather.Errored(error: WeatherError.decoding)
        spy = SpyWeather(expectation: expectation)
        sut = Weather(currentWeatherWorkers: [worker])
        sut!.current(output: spy!)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNil(spy!.items)
        XCTAssertNotNil(spy!.error)
    }
    
}

private class MockWeather {
    internal class Success:Worker{
        let weather:InstantWeather
        init(weather:InstantWeather) {
            self.weather = weather
        }
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            resolve(self, weather)
        }
    }
    internal class Errored:Worker{
        let error:Error
        init(error:Error) {
            self.error = error
        }
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            reject(self, error)
        }
    }
}

class SpyWeather:MockExpectation, WeatherOutputProtocol{
    
    var items:Array<InstantWeather>?
    var error:Error?
    
    func onWeather(items: Array<InstantWeather>) {
        self.items = items
        expectation.fulfill()
    }
    
    func onWeatherError(error: Error) {
        self.error = error
        expectation.fulfill()
    }
}
