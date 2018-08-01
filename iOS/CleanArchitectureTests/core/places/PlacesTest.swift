//
//  PlacesTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 7/5/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class PlacesTest: XCTestCase {
    
    private var sut:Places?
    private var spy:PlacesOutput?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        spy = PlacesOutput()
    }
    
    override func tearDown() {
        sut = nil
        spy = nil
        super.tearDown()
    }
    
    func testGivenNoLocationPermissionWhenGetNearbyThrowError() {
        let expectation = XCTestExpectation(description: "testGivenNoLocationPermissionWhenGetNearbyThrowError")
        sut = Places(locationWorker:MockNoLocationPermissionWork(expectation: expectation), placesGateway:MockSuccessPlacesWork(expectation: XCTestExpectation(description: "not used expectation")))
        sut!.nearby(output: spy!)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNil(spy!.places)
        XCTAssertNotNil(spy!.error!)
        if case LocationError.noLocationPermission = spy!.error! {
            //ok
        }else{
            XCTFail("wrong error, expected: LocationError.noLocationPermission actual:\(String(describing: spy!.error!.self))")
        }
    }
    
    func testGivenLocationWhenGetNearbyThenReturnOne() {
        let expectationLocation = XCTestExpectation(description: "testGivenNoLocationPermissionWhenGetNearbyThrowError - location")
        let expectationNearby = XCTestExpectation(description: "testGivenNoLocationPermissionWhenGetNearbyThrowError - nearby")
        sut = Places(locationWorker:MockSuccessLocationWork(expectation: expectationLocation), placesGateway:MockSuccessPlacesWork(expectation: expectationNearby))
        sut!.nearby(output: spy!)
        wait(for: [expectationLocation, expectationNearby], timeout: 0.1)
        XCTAssertNil(spy!.error)
        XCTAssertNotNil(spy!.places)
        XCTAssertEqual(spy?.places?.count, 1)
    }
}

class MockExpectation{
    let expectation:XCTestExpectation
    init(expectation:XCTestExpectation) {
        self.expectation = expectation
    }
}

class MockNoLocationPermissionWork: MockExpectation, Worker {
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        reject(self, LocationError.noLocationPermission)
        expectation.fulfill()
    }
}

class MockSuccessLocationWork: MockExpectation, Worker {
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        resolve(self, Location(latitude: 43.0, longitude: -8.0))
        expectation.fulfill()
    }
}

class MockSuccessPlacesWork:MockExpectation, Worker {
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        resolve(self, [Place(id: "1", placeId: "1", name: "place", icon:"icon", openNow: false, rating: 5.0, location: params as! Location)])
        expectation.fulfill()
    }
}

class PlacesOutput: PlacesOutputProtocol {
    
    var places:Array<Place>?
    var error:Error?
    
    func onNearby(places: Array<Place>) {
        self.places = places
    }
    
    func onNearbyError(error: Error) {
        self.error = error
    }
}
