//
//  AirQualityViewControllerUITest.swift
//  CleanArchitectureUITests
//
//  Created by Alberto on 29/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import CoreLocation
@testable import CleanArchitecture

class AirQualityViewControllerUITest: XCTestCase {
    
    private var testTool = UITestNavigationTool<AirQualityViewController>()
    private var sut:AirQualityViewController?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        testTool.tearDown()
        super.tearDown()
    }
    
    func testGivenViewDidLoadWhenGetAirQualityThenShowLoading() {
        let mockPresenter = Mock.AirQualityPresenter()
        mockPresenter.vs = AirQualityViewState(status: .loading, airQuality: nil, error: nil, reqPermission: false)
        sut = AirQualityViewController(presenter: mockPresenter, locationManager: Mock.LocationManager())
        mockPresenter.view = sut
        testTool.setUp(withViewController: sut!)
        XCTAssertFalse(sut!.activityIndicator!.isHidden)
        XCTAssertTrue(sut!.errorLabel!.isHidden)
        XCTAssertTrue(sut!.reloadButton!.isHidden)
    }
    
    func testGivenModelReturnsDataWhenGetAirQualityThenShowData() {
        let mockPresenter = Mock.AirQualityPresenter()
        let airQuality = AirQualityResultViewModel(latitude: 43, longitude: -8, date: "now", aqi: "Low", aqiColor: "Green", no2: "40μg/m3", o3: "10μg/m3", pm10: "5μg/m3", pm2_5: "1μg/m3")
        mockPresenter.vs = AirQualityViewState(status: .success, airQuality: airQuality, error: nil, reqPermission: false)
        sut = AirQualityViewController(presenter: mockPresenter, locationManager: Mock.LocationManager())
        mockPresenter.view = sut
        testTool.setUp(withViewController: sut!)
        XCTAssertTrue(sut!.activityIndicator!.isHidden)
        XCTAssertTrue(sut!.errorLabel!.isHidden)
        XCTAssertTrue(sut!.reloadButton!.isHidden)
        XCTAssertEqual(sut!.airQualityLabel.text, airQuality.aqi)
        XCTAssertEqual(sut!.no2Label.text, airQuality.no2)
        XCTAssertEqual(sut!.o3Label.text, airQuality.o3)
        XCTAssertEqual(sut!.pm10Label.text, airQuality.pm10)
        XCTAssertEqual(sut!.pm2_5Label.text, airQuality.pm2_5)
    }
    
    func testGivenModelReturnsErrorWhenGetAirQualityThenShowError() {
        let mockPresenter = Mock.AirQualityPresenter()
        let error = "Faked error"
        mockPresenter.vs = AirQualityViewState(status: .error, airQuality: nil, error: error, reqPermission: false)
        sut = AirQualityViewController(presenter: mockPresenter, locationManager: Mock.LocationManager())
        mockPresenter.view = sut
        testTool.setUp(withViewController: sut!)
        XCTAssertTrue(sut!.activityIndicator!.isHidden)
        XCTAssertFalse(sut!.errorLabel!.isHidden)
        XCTAssertFalse(sut!.reloadButton!.isHidden)
        XCTAssertEqual(sut!.errorLabel.text, error)
    }
}

private class Mock {
    internal class AirQualityPresenter:AirQualityPresenterProtocol {
        
        var view:AirQualityViewProtocol?
        var vs:AirQualityViewState?
        
        func getAirQuality() {
            view?.newState(airQualityViewState: vs!)
        }
    }
    
    internal class LocationManager:CLLocationManager{}
}
