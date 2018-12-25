//
//  CurrentWeatherPresenterTests.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 24/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import Nimble
@testable import CleanArchitecture

class CurrentWeatherPresenterTests: XCTestCase {
    
    private var sut: CurrentWeatherPresenter!
    private var mockCurrentWeather: MockCurrentWeather!
    private var spyView: SpyView!
    
    override func setUp() {
        super.setUp()
        mockCurrentWeather = MockCurrentWeather()
        spyView = SpyView()
        sut = CurrentWeatherPresenter(currentWeather: mockCurrentWeather)
        sut.view = spyView
    }
    
    override func tearDown() {
        sut = nil
        mockCurrentWeather = nil
        spyView = nil
        super.tearDown()
    }
    
    func test_when_get_current_weather_then_view_show_loading() {
        mockCurrentWeather.closure = { }
        
        sut.current()
        
        expect(self.spyView.invokedShowLoading).toEventually(beTrue())
    }
    
    func test_given_no_location_permissions_when_get_current_weather_then_ask_for_them() {
        mockCurrentWeather.closure = { self.sut.weatherError(error: CurrentWeatherError.noLocationPermission) }
        
        sut.current()
        
        expect(self.spyView.invokedAskedLocationPermissions).toEventually(beTrue())
        expect(self.spyView.invokedHideLoading).toEventually(beTrue())
    }

    func test_given_success_getting_weather_when_get_current_weather_then_show_correctly() {
        let weather = InstantWeather(name: "Lodon", description: "Mist", icon: "", temp: 15, pressure: 1024, humidity: 75, windSpeed: 20, windDegrees: 90, datetime: 0)
        mockCurrentWeather.closure = { self.sut.weather(weather: weather) }
        
        sut.current()
        
        expect(self.spyView.invokedHideLoading).toEventually(beTrue())
        expect(self.spyView.viewModel.city).toEventually(equal(weather.name))
        expect(self.spyView.viewModel.description).toEventually(equal(weather.description))
        expect(self.spyView.viewModel.temperature).toEventually(equal("\(weather.temp)k"))
        expect(self.spyView.viewModel.pressure).toEventually(equal("\(weather.pressure)hPa"))
        expect(self.spyView.viewModel.humidity).toEventually(equal("\(weather.humidity)%"))
        expect(self.spyView.viewModel.windSpeed).toEventually(equal("\(weather.windSpeed)m/s"))
    }
    
    func test_given_internal_error_when_get_current_weather_then_show_error() {
        mockCurrentWeather.closure = { self.sut.weatherError(error: CurrentWeatherError.noPermissions) }
        
        sut.current()
        
        expect(self.spyView.invokedError).toEventually(beTrue())
        expect(self.spyView.invokedHideLoading).toEventually(beTrue())
    }
}

private final class MockCurrentWeather: CurrentWeatherProtocol {
    
    var closure: (() -> Void)!
    
    func current(output: CurrentWeatherOutputProtocol) {
        closure()
    }
    
}

private final class SpyView: CurrentWeatherViewProtocol {
    
    var invokedShowLoading = false
    var invokedHideLoading = false
    var invokedAskedLocationPermissions = false
    var invokedShow = false
    var viewModel: CurrentWeatherViewModel!
    var invokedError = false
    
    func show(viewModel: CurrentWeatherViewModel) {
        invokedShow = true
        self.viewModel = viewModel
    }
    
    func askLocationPermission() {
        invokedAskedLocationPermissions = true
    }
    
    func error(message: String) {
        invokedError = true
    }
    
    func hideLoading() {
        invokedHideLoading = true
    }
    
    func showLoading() {
        invokedShowLoading = true
    }
    
}
