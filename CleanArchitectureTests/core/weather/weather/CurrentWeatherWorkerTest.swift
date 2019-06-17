//
//  CurrentWeatherWorkerTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 19/3/19.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import CleanArchitecture

class CurrentWeatherWorkerTest: XCTestCase {
    
    private lazy var url = "https://\(host)\(path)?q=TestCity&appid=TestApiKey"
    private var host: String { return service!.urlRequest.url!.host! }
    private let path = "/data/2.5/weather"
    private let location = Location(latitude: 43.0, longitude: -8.1)
    private let city: String = "TestCity"
    private lazy var params = [
        "q": self.city,
        "appid": Constants.openWeatherApiKey
    ]
    private var service: WeatherService!
    private var sut: CurrentWeatherWorker!
    
    override func setUp() {
        super.setUp()
        service = WeatherService(city: city)
        sut = CurrentWeatherWorker(city: city)
        OHHTTPStubs.onStubActivation { (request, stub, _) in
            print("** OHHTTPStubs: \(request.url!.absoluteString) stubbed by \(stub.name!). **")
        }
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        service = nil
        sut = nil
        super.tearDown()
    }
    
    func testGivenSuccessEnvWhenGetWeatherThenMatchResult() throws {
        let response = try OHHTTPStubsResponse._200(jsonFileName: "current-weather-success.json", inBundleForClass: type(of: self))
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return response
        }.name = "get weather success request"
        
        
        var result: InstantWeather?
        try sut.run(params: nil, resolve: { (worker, res) in
            result = res as? InstantWeather
        }) { (worker, error) in }
        
        expect(result).toNotEventually(beNil())
        let weather = try result.unwrap()
        expect(weather.name).toEventually(equal("London"))
        expect(weather.description).toEventually(equal("light intensity drizzle"))
        expect(weather.datetime).toEventually(equal(1485789600))
        expect(weather.humidity).toEventually(equal(81.0))
        expect(weather.icon).toEventually(equal("09d"))
        expect(weather.pressure).toEventually(equal(1012.1))
        expect(weather.temp).toEventually(equal(280.32))
        expect(weather.windDegrees).toEventually(equal(80))
        expect(weather.windSpeed).toEventually(equal(4.1))
    }
    
    func testGivenErrorEnvWhenGetWeatherThenMatchError() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse._400()
        }.name = "weather error network request"
        
        var error: WeatherError?
        try sut.run(params: nil, resolve: { (worker, result) in }) { (worker, err) in
            error = err as? WeatherError
        }
        
        expect(error).toEventually(equal(WeatherError.other))
    }
}
