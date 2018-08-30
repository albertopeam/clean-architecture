//
//  UVIndexWorkerTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class UVIndexWorkerTest: NetworkTestCase {
    
    var sut:UVIndexWorker?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testGivenSuccessServerWhenGetUVIndexThenMatchParseIsCorrect() throws {
        let location = Location(latitude: 37.75, longitude: -122.37)
        let absoluteUrl = "\(serverUrl())uvi?lat=\(location.latitude)&lon=\(location.longitude)&appid=TestApiKey"
        dispatchResponseToGetRequest(url: absoluteUrl, fileName: "uvindex-success")
        sut = UVIndexWorker(url: absoluteUrl)
        let expectation = XCTestExpectation(description: "testGivenSuccessServerWhenGetUVIndexThenMatchParseIsCorrect")
        try sut!.run(params: location, resolve: { (worker, result) in
            XCTAssertNotNil(result)
            let result = result as! UltravioletIndex
            XCTAssertEqual(result.uvIndex, 10.06)
            XCTAssertEqual(result.date, "2017-06-26T12:00:00Z")
            XCTAssertEqual(result.timestamp, 1498478400)
            XCTAssertEqual(result.location.latitude, 37.75)
            XCTAssertEqual(result.location.longitude, -122.37)
            expectation.fulfill()
        }, reject: { (worker, error) in
            XCTFail("testGivenSuccessServerWhenGetUVIndexThenMatchParseIsCorrect rejected")
        })
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    func testGivenNetworkErrorWhenGetUVIndexThenMatchReject() throws {
        let location = Location(latitude: 37.75, longitude: -122.37)
        let absoluteUrl = "\(serverUrl())uvi?lat=\(location.latitude)&lon=\(location.longitude)&appid=TestApiKey"
        dispatchErrorResponseToGetRequest(statusCode: 400, status: "Bad Request", url: absoluteUrl)
        sut = UVIndexWorker(url: absoluteUrl)
        let expectation = XCTestExpectation(description: "testGivenNetworkErrorWhenGetUVIndexThenMatchReject")
        try sut!.run(params: location, resolve: { (worker, result) in
            XCTFail("testGivenNetworkErrorWhenGetUVIndexThenMatchReject rejected")
        }, reject: { (worker, error) in
            XCTAssertTrue(error.code == UVIndexError.other.code)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
}
