//
//  CurrentWeatherViewControllerUITests.swift
//  CleanArchitectureUITests
//
//  Created by Alberto on 23/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class CurrentWeatherViewControllerUITests: XCTestCase {
    
    private var robot: CurrentWeatherRobot!
    
    override func setUp() {
        super.setUp()
        robot = CurrentWeatherRobot(test: self)
    }
    
    override func tearDown() {
        robot = nil
        super.tearDown()
    }
    
    func test_given_no_response_weather_when_ask_current_weather_then_show_loading() {
        robot.present(vc: CurrentWeatherViewBuilder().build())
            .assertLoading()
    }
    
    func test_given_success_response_weather_when_ask_current_weather_then_show_weather() {
        let mockSession = MockURLSession(data: weatherData(), response: MockURLResponse())
        let vc = CurrentWeatherViewBuilder()
            .withLocationJob(locationJob: MockLocationJob(mockLocation: Location(latitude: 0.0, longitude: 0.0)))
            .withWeatherJob(weatherJob: CurrentWeatherJob(urlSession: mockSession))
            .build()        
        robot.present(vc: vc)
            .assertWeather()
    }
    
    private func weatherData() -> Data {
        let js: [String: Any] = [
            "cod": 200,
            "name": "Perillo",
            "dt": 1545605544,
            "weather": [[
                "description": "description",
                "icon": "icon"
                ]],
            "main": [
                "temp": 20.0,
                "pressure":1024.0,
                "humidity":75
            ],
            "wind": [
                "speed": 20,
                "deg": 90
            ]
        ]
        if let data = try? JSONSerialization.data(withJSONObject: js, options: .prettyPrinted) {
            return data
        }
        preconditionFailure("cannot convert to data")
    }
    
}

final class CurrentWeatherRobot: UIRobot {
 
    @discardableResult
    func present(vc: UIViewController) -> CurrentWeatherRobot {
        present(viewController: vc)
        return self
    }
    
    @discardableResult
    func assertLoading() -> CurrentWeatherRobot {
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.loading)
        return self
    }
    
    @discardableResult
    func assertWeather() -> CurrentWeatherRobot {
        tester!.waitForView(withAccessibilityIdentifier: "")
        return self
    }
    
}

private final class MockLocationJob: LocationJob {
    
    private let mockLocation: Location
    
    init(mockLocation: Location) {
        self.mockLocation = mockLocation
    }
    
    override func location() -> Promise<Location> {
        return Promise<Location>(value: mockLocation)
    }
    
}

//Sundell https://medium.com/@johnsundell/mocking-in-swift-56a913ee7484
class MockURLSession: URLSession {
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var error: Error?
    var response: URLResponse?
    
    init(data: Data, response: URLResponse) {
        self.data = data
        self.response = response
    }
    
    init(error: Error, response: URLResponse) {
        self.error = error
        self.response = response
    }
    
    override func dataTask(with url: URL,
                           completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        return MockURLSessionDataTask {
            completionHandler(data, nil, error)
        }
    }
    
}

//Sundell https://medium.com/@johnsundell/mocking-in-swift-56a913ee7484
class MockURLSessionDataTask: URLSessionDataTask {
    
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

class MockURLResponse: URLResponse {}
