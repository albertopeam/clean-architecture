//
//  WeatherPresenterTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 20/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class WeatherPresenterTest: XCTestCase {
    
    private var sut:WeatherPresenter?
    private var vm:WeatherViewModel?
    private var spyView:Spy.WeatherView?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        vm = WeatherViewModel()
        spyView = Spy.WeatherView()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        vm = nil
        spyView = nil
    }
    
    func testGivenSuccessEnvWhenGetWeatherThenVMHasInstantWeatherAndNoError() {
        sut = WeatherPresenter(weather: Mock.SuccessWeather(), viewModel:vm!, view:spyView!)
        sut?.weathers()
        XCTAssertNotNil(spyView!.vm)
        let targets = spyView!.vm!
        XCTAssertNil(targets.error)
        XCTAssertNotNil(targets.weathers)
        XCTAssertEqual(targets.weathers!.count, 1)
        let target = targets.weathers![0]
        XCTAssertEqual(target.name, "name")
        XCTAssertEqual(target.description, "description")
        XCTAssertEqual(target.icon, "icon")
        XCTAssertEqual(target.temp, -273.15)
        XCTAssertEqual(target.pressure, 1000)
        XCTAssertEqual(target.humidity, 75.0)
        XCTAssertEqual(target.windSpeed, 5.0)
        XCTAssertEqual(target.windDegrees, 90.0)
        XCTAssertEqual(target.datetime, 1485792967)
        
    }
    
    func testGivenSuccessEnvWhenGetWeatherThenVMHasErrorAndNoInstantWeather() {
        sut = WeatherPresenter(weather: Mock.ErrorWeather(), viewModel:vm!, view:spyView!)
        sut?.weathers()
        XCTAssertNotNil(spyView!.vm)
        let targets = spyView!.vm!
        XCTAssertNotNil(targets.error)
        XCTAssertNil(targets.weathers)
        let error = targets.error!
        XCTAssertEqual(error, "Mock.ErrorWeather")
    }
    
}

private class Mock{
    internal class SuccessWeather:WeatherProtocol{
        func current(output: WeatherOutputProtocol) {
            let weather = InstantWeather(name: "name", description: "description", icon: "icon", temp: -273.15, pressure: 1000, humidity: 75.0, windSpeed: 5.0, windDegrees: 90.0, datetime: 1485792967)
            output.onWeather(items: [weather])
        }
    }
    
    internal class ErrorWeather:WeatherProtocol{
        func current(output: WeatherOutputProtocol) {
            output.onWeatherError(error: NSError(domain: "Mock.ErrorWeather", code: 0, userInfo: nil))
        }
    }
}

private class Spy{
    internal class WeatherView:WeatherViewProtocol{
        
        var vm:WeatherViewModel?
        
        func newState(viewModel: WeatherViewModel) {
            self.vm = viewModel
        }
        
    }
}
