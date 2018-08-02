//
//  UVIndexTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class UVIndexTest: XCTestCase {
    
    private var sut:UVIndex?
    private var spy:SpyUVIndex.Output?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        spy = nil
    }
    
    func testGivenLocationAndServerSuccessWhenGetUVIndexThenMatchUltravioletIndex() {
        let location = Location(latitude: 43.0, longitude: -8.0)
        let now = Date()
        let formatter = ISO8601DateFormatter()
        let date = formatter.string(from: now)
        let uvIndex = UltravioletIndex(location: location, date: date, timestamp: Int(now.timeIntervalSince1970), uvIndex: 1)
        let locationWorker = MockLocation.Success(location: location)
        let uvIndexWorker = MockUVIndex.Success(ultravioletIndex: uvIndex)
        let expectation = XCTestExpectation(description: "testGivenLocationAndServerSuccessWhenGetUVIndexThenMatchUltravioletIndex")
        spy = SpyUVIndex.Output(expectation: expectation)
        sut = UVIndex(locationWorker: locationWorker, uvIndexWorker: uvIndexWorker)
        sut!.UVIndex(output: spy!)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(spy?.ultravioletIndex?.date, uvIndex.date)
        XCTAssertEqual(spy?.ultravioletIndex?.timestamp, uvIndex.timestamp)
        XCTAssertEqual(spy?.ultravioletIndex?.uvIndex, uvIndex.uvIndex)
        XCTAssertEqual(spy?.ultravioletIndex?.location.latitude, uvIndex.location.latitude)
        XCTAssertEqual(spy?.ultravioletIndex?.location.longitude, uvIndex.location.longitude)
    }
    
    func testGivenLocationAndServerErrorWhenGetUVIndexThenMatchError() {
        //TODO:
    }
}

private class MockUVIndex {
    internal class Success:Worker{
        let ultravioletIndex:UltravioletIndex
        init(ultravioletIndex:UltravioletIndex) {
            self.ultravioletIndex = ultravioletIndex
        }
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            resolve(self, ultravioletIndex)
        }
    }
    
}

private class SpyUVIndex{
    internal class Output:MockExpectation, UVIndexOutputProtocol{
        var ultravioletIndex: UltravioletIndex?
        var error:Error?
        
        func onUVIndex(ultravioletIndex: UltravioletIndex) {
            self.ultravioletIndex = ultravioletIndex
            expectation.fulfill()
        }
        
        func onUVIndexError(error: Error) {
            self.error = error
            expectation.fulfill()
        }
    }
}
