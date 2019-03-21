//
//  CurrentWeatherTests.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 24/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import Nimble
@testable import CleanArchitecture

class CurrentWeatherTests: XCTestCase {
    
    private var sut: CurrentWeather!
    private var mockLocationJob: MockLocationJob!
    private var mockCurrentWeatherJob: MockCurrentWeatherJob!
    private var spy: SpyCurrentWeatherOutput!
    
    override func setUp() {
        super.setUp()
        mockLocationJob = MockLocationJob()
        mockCurrentWeatherJob = MockCurrentWeatherJob(urlSession: DummyURLSession())
        spy = SpyCurrentWeatherOutput()
        sut = CurrentWeather(locationJob: mockLocationJob, weatherJob: mockCurrentWeatherJob)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_given_no_location_permission_when_get_current_then_match_error() {
        mockLocationJob.closure = {
            let promise = Promise<Location>()
            DispatchQueue.main.async {
                promise.reject(with: LocationError.noLocationPermission)
            }
            return promise
        }
        
        sut.current(output: spy)
        
        expect(self.spy.error).toEventually(matchError(CurrentWeatherError.noLocationPermission))
        expect(self.spy.weather).toEventually(beNil())
    }
    
    func test_given_success_location_and_network_when_get_current_then_weather() {
        let weather = InstantWeather(name: "", description: "", icon: "", temp: 1, pressure: 1, humidity: 1, windSpeed: 1, windDegrees: 1, datetime: 1)
        mockLocationJob.closure = { return Promise<Location>(value: Location(latitude: 0, longitude: 0)) }
        mockCurrentWeatherJob.closure = { return Promise<InstantWeather>(value: weather) }
        
        sut.current(output: spy)
        
        expect(self.spy.error).toEventually(beNil())
        expect(self.spy.weather).toEventually(equal(weather))
    }
    
}

private final class MockLocationJob: LocationJob {
    
    var closure: (() -> Promise<Location>)!
    
    override func location() -> Promise<Location> {
        return closure()
    }
}

private final class MockCurrentWeatherJob: CurrentWeatherJob {
    
    var closure: (() -> Promise<InstantWeather>)!
    
    override func weather(location: Location)  -> Promise<InstantWeather> {
        return closure()
    }
}

private final class SpyCurrentWeatherOutput: CurrentWeatherOutputProtocol {
    
    var weather: InstantWeather!
    var error: CurrentWeatherError!
    
    func weather(weather: InstantWeather) {
        self.weather = weather
    }
    
    func weatherError(error: CurrentWeatherError) {
        self.error = error
    }
    
}

private class DummyURLSession: URLSession {}
