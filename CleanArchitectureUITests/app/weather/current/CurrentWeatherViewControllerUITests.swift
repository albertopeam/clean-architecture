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
        let vc = CurrentWeatherViewBuilder()
            .withLocationJob(locationJob: DummyLocationJob())
            .build()
        robot.present(vc: vc)
            .assertLoading()
    }
    
    func test_given_success_response_weather_when_ask_current_weather_then_show_weather() {
        let mockSession = MockURLSession(data: weatherData())
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
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.city)
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.description)
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.humidity)
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.pressure)
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.pressure)
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.windSpeed)
        return self
    }
    
    @discardableResult
    func assertWeather() -> CurrentWeatherRobot {
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.loading)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.city)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.description)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.humidity)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.pressure)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.pressure)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.windSpeed)
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

private final class DummyLocationJob: LocationJob {
    override func location() -> Promise<Location> {
        return Promise<Location>()
    }
}
