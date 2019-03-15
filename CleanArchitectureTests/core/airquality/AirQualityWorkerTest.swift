////
////  AirQualityWorkerTest.swift
////  CleanArchitectureTests
////
////  Created by Alberto on 29/8/18.
////  Copyright © 2018 Alberto. All rights reserved.
////
//
//import XCTest
//@testable import CleanArchitecture
//
//class AirQualityWorkerTest: NetworkTestCase {
//    
//    private var sut:AirQualityWorker?
//    
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//    }
//    
//    override func tearDown() {        
//        super.tearDown()
//        sut = nil
//    }
//    
//    func testGivenSuccessResponseWhenFetchThenMatchExpectedData() {
//        let location = Location(latitude: 43.0, longitude: -8.1)
//        let parameter = "no2"
//        let absoluteUrl = "\(serverUrl())v1/measurements?coordinates={{lat}},{{lon}}&limit=1&parameter=\(parameter)&has_geo=true"
//        dispatchResponseToGetRequest(url: absoluteUrl, fileName: "airquality-success")
//        sut = AirQualityWorker(url: absoluteUrl)
//        let expectation = XCTestExpectation(description: "testGivenSuccessResponseWhenFetchThenMatchExpectedData")
//        try! sut!.run(params: location, resolve: { (worker, result) in
//            XCTAssertNotNil(result)
//            let res = result as! AirQualityData
//            XCTAssertEqual(res.type, "no2")
//            XCTAssertEqual(res.date, "utc-date")
//            XCTAssertEqual(res.location.latitude, 43.0)
//            XCTAssertEqual(res.location.longitude, -8.1)
//            XCTAssertEqual(res.measure.value, 10)
//            XCTAssertEqual(res.measure.unit, "µg/m³")
//            expectation.fulfill()
//        }) { (worker, error) in
//            XCTFail("testGivenSuccessResponseWhenFetchThenMatchExpectedData rejected")
//        }
//        wait(for: [expectation], timeout: TestConstants.timeout)
//    }
//    
//}

import XCTest
import OHHTTPStubs
import Nimble
@testable import CleanArchitecture

class AirQualityWorkerTest: XCTestCase {
    
    private lazy var endpoint = "https://\(host)/"
    private let host = "any"
    
    func test_GivenSuccessResponseWhenFetchThenMatchExpectedData() throws {
        let location = Location(latitude: 43.0, longitude: -8.1)
        let parameter = "no2"
        let absoluteUrl = "\(endpoint)v1/measurements?coordinates={{lat}},{{lon}}&limit=1&parameter=\(parameter)&has_geo=true"
        var mockUrl = absoluteUrl.replacingOccurrences(of: "{{lat}}", with: "\(location.latitude)")
        mockUrl = mockUrl.replacingOccurrences(of: "{{lon}}", with: "\(location.longitude)")
        let params: [String: String] = [
            "coordinates": "\(location.latitude),\(location.longitude)",
            "limit": "1",
            "parameter": parameter,
            "has_geo": "true"]
        stub(condition: isMethodGET() && isHost(host) && isPath("/v1/measurements") && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("airquality-success.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }
        let sut = AirQualityWorker(url: absoluteUrl)
        var result: AirQualityData?
        try sut.run(params: location, resolve: { (worker, res) in
            result = res as? AirQualityData
        }) { (worker, error) in }
        expect(result).toNotEventually(beNil())
        let unwrapped = try result.unwrap()
        expect(unwrapped.type).to(equal("no2"))
        expect(unwrapped.date).to(equal("utc-date"))
        expect(unwrapped.location.latitude).to(equal(43.0))
        expect(unwrapped.location.longitude).to(equal(-8.1))
        expect(unwrapped.measure.value).to(equal(10))
        expect(unwrapped.measure.unit).to(equal("µg/m³"))
    }
    
}
