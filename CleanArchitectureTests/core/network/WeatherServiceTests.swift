//
//  WeatherServiceTests.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 30/05/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import Nimble

class WeatherServiceTests: XCTestCase {

    func test_given_open_weather_service_when_get_request_then_match() {
        let sut = WeatherService(city: "A Coruña")
        
        let request = sut.urlRequest
        expect(request.url?.absoluteString).to(equal("https://api.openweathermap.org/data/2.5/weather?q=A%20Coru%C3%B1a&appid=\(Constants.openWeatherApiKey)"))
        expect(request.httpMethod).to(equal("GET"))
    }

}
