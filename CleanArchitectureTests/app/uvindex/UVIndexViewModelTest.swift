//
//  UVIndexViewModelTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class UVIndexViewModelTest: XCTestCase {
    
    private var sut:UVIndexViewModel?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGivenSuccessWhenGettingUVIndexThenModifyStateProperly() {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        let date = formatter.string(from: now)
        let location:Location = Location(latitude: 43.0, longitude: -8.0)
        let uvIndex = UltravioletIndex(location: location, date: date, timestamp: Int(now.timeIntervalSince1970), uvIndex: 1)
        let mockUVIndex = Mock.SuccessUVIndex(ultravioletIndex: uvIndex)
        sut = UVIndexViewModel(uvIndex: mockUVIndex)
        sut!.loadUVIndex()
        XCTAssertTrue(sut!.viewStateObservable.value == .success)
        XCTAssertEqual(sut!.uvIndexObservable.value, "1")
        XCTAssertEqual(sut!.uvIndexColorObservable.value, "Green")
        XCTAssertEqual(sut!.descriptionObservable.value, "Low")
        XCTAssertEqual(sut!.locationObservable.value.latitude, 43.0)
        XCTAssertEqual(sut!.locationObservable.value.longitude, -8.0)
        XCTAssertTrue(sut!.locationPermissionObservable.value)
        XCTAssertEqual(sut!.errorObservable.value, "")
    }
    
    func testGivenErrorWhenGettingUVIndexThenModifyStateProperly() {
        let mockUVIndex = Mock.ErrorUVIndex(error: LocationError.noLocationPermission)
        sut = UVIndexViewModel(uvIndex: mockUVIndex)
        sut!.loadUVIndex()
        XCTAssertTrue(sut!.viewStateObservable.value == .error)
        XCTAssertEqual(sut!.errorObservable.value, "Location services require permission")
        XCTAssertFalse(sut!.locationPermissionObservable.value)
    }
}

private class Mock {
    internal class SuccessUVIndex:UVIndexProtocol {
        var ultravioletIndex:UltravioletIndex
        init(ultravioletIndex:UltravioletIndex) {
            self.ultravioletIndex = ultravioletIndex
        }
        func UVIndex(output: UVIndexOutputProtocol) {
            output.onUVIndex(ultravioletIndex: ultravioletIndex)
        }
    }
    internal class ErrorUVIndex:UVIndexProtocol {
        var error:Error
        init(error:Error) {
            self.error = error
        }
        func UVIndex(output: UVIndexOutputProtocol) {
            output.onUVIndexError(error: error)
        }
    }
}
