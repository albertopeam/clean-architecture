//
//  AirQualityWorkerTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 29/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class AirQualityWorkerTest: NetworkTestCase {
    
    private var sut:AirQualityWorker?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {        
        super.tearDown()
        sut = nil
    }
    
    func testGivenSuccessResponseWhenFetchThenMatchExpectedData() {
        let location = Location(latitude: 43.0, longitude: -8.1)
        let parameter = "no2"
        let absoluteUrl = "\(serverUrl())v1/measurements?coordinates={{lat}},{{lon}}&limit=1&parameter=\(parameter)&has_geo=true"
        dispatchResponseToGetRequest(url: absoluteUrl, fileName: "airquality-success")
        sut = AirQualityWorker(url: absoluteUrl)
        let expectation = XCTestExpectation(description: "testGivenSuccessResponseWhenFetchThenMatchExpectedData")
        try! sut!.run(params: location, resolve: { (worker, result) in
            XCTAssertNotNil(result)
            let res = result as! AirQualityData
            XCTAssertEqual(res.type, "no2")
            XCTAssertEqual(res.date, "utc-date")
            XCTAssertEqual(res.location.latitude, 43.0)
            XCTAssertEqual(res.location.longitude, -8.1)
            XCTAssertEqual(res.measure.value, 10)
            XCTAssertEqual(res.measure.unit, "µg/m³")
            expectation.fulfill()
        }) { (worker, error) in
            XCTFail("testGivenSuccessResponseWhenFetchThenMatchExpectedData rejected")
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
}
