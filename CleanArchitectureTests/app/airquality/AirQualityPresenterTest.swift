//
//  AirQualityPresenterTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 29/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class AirQualityPresenterTest: XCTestCase {
    
    private var sut:AirQualityPresenter?
    private var spyView:Spy.AirQualityView?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        spyView = Spy.AirQualityView()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        spyView = nil
    }
    
    func testGivenModelWaitingForDataWhenGetAirQualityThenStateLoading() {
        let mockAirQuality = Mock.LoadingAirQuality()
        sut = AirQualityPresenter(airQuality: mockAirQuality, airQualityState: AirQualityViewState(status: .loading, airQuality: nil, error: nil, reqPermission: false))
        sut!.view = spyView!
        sut!.getAirQuality()
        XCTAssertNotNil(spyView!.airQualityViewState!)
        XCTAssertEqual(spyView!.airQualityViewState?.status, .loading)
    }
    
    func testGivenModelReturnsDataWhenGetAirQualityThenFormatData() {
        let measure = Measure(value: 5, unit: "µg/m³")
        let result = AirQualityResult(location: Location(latitude: 43, longitude: -8), date: Date(), aqi: AQIName.m, no2: measure, o3: measure, pm10: measure, pm2_5: measure)
        let mockAirQuality = Mock.SuccessAirQuality(result: result)
        sut = AirQualityPresenter(airQuality: mockAirQuality, airQualityState: AirQualityViewState(status: .loading, airQuality: nil, error: nil, reqPermission: false))
        sut!.view = spyView!
        sut!.getAirQuality()
        XCTAssertNotNil(spyView!.airQualityViewState!)
        XCTAssertNotNil(spyView!.airQualityViewState!.airQuality)
        XCTAssertNil(spyView!.airQualityViewState!.error)
        XCTAssertFalse(spyView!.airQualityViewState!.reqPermission)
        XCTAssertEqual(spyView!.airQualityViewState!.status, .success)
        XCTAssertEqual(spyView!.airQualityViewState?.airQuality?.no2, "NO2: \(result.no2.value) \(result.no2.unit)")
        XCTAssertEqual(spyView!.airQualityViewState?.airQuality?.o3, "O3: \(result.o3.value) \(result.o3.unit)")
        XCTAssertEqual(spyView!.airQualityViewState?.airQuality?.pm10, "PM10: \(result.pm10.value) \(result.pm10.unit)")
        XCTAssertEqual(spyView!.airQualityViewState?.airQuality?.pm2_5, "PM2.5: \(result.pm2_5.value) \(result.pm2_5.unit)")
    }
    
    func testGivenModelReturnsErrorWhenGetAirQualityThenFormatError() {
        let mockAirQuality = Mock.ErrorAirQuality(error: AirQualityError.noNetwork)
        sut = AirQualityPresenter(airQuality: mockAirQuality, airQualityState: AirQualityViewState(status: .loading, airQuality: nil, error: nil, reqPermission: false))
        sut!.view = spyView!
        sut!.getAirQuality()
        XCTAssertNotNil(spyView!.airQualityViewState!)
        XCTAssertNotNil(spyView!.airQualityViewState!.error)
        XCTAssertNil(spyView!.airQualityViewState!.airQuality)
        XCTAssertEqual(spyView!.airQualityViewState?.error, "No network")
    }
}

private class Mock {
    internal class SuccessAirQuality:AirQualityProtocol {
        
        var result:AirQualityResult
        
        init(result:AirQualityResult) {
            self.result = result
        }
        
        func getAirQuality(output: AirQualityOutputProtocol) {
            output.onGetAirQuality(airQuality: result)
        }
    }
    internal class LoadingAirQuality:AirQualityProtocol{
        func getAirQuality(output: AirQualityOutputProtocol) {}
    }
    internal class ErrorAirQuality:AirQualityProtocol{
        
        let error:Error
        
        init(error:Error) {
            self.error = error
        }
        
        func getAirQuality(output: AirQualityOutputProtocol) {
            output.onErrorAirQuality(error: error)
        }
    }
}

private class Spy {
    internal class AirQualityView:AirQualityViewProtocol{
        
        var airQualityViewState:AirQualityViewState?
        
        func newState(airQualityViewState: AirQualityViewState) {
            self.airQualityViewState = airQualityViewState
        }
    }
}
