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
        robot.present()
            .assertLoading()
    }
    
    func test_given_success_response_weather_when_ask_current_weather_then_show_weather() {
        robot.present()
            .assertWeather()
    }
    
}

final class CurrentWeatherRobot: UIRobot {
 
    @discardableResult
    func present() -> CurrentWeatherRobot {
        let vc = CurrentWeatherViewBuilder.build()
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
