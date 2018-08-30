//
//  PlacesGatewayTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 7/5/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class PlacesWorkerTest: NetworkTestCase {
    
    var sut:PlacesWorker?
    
    override func setUp(){
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testGivenValidInputWhenGetNearbyThenReturnSuccess() throws {
        let location = Location(latitude: 43.0, longitude: -8)
        let absoluteUrl = "\(serverUrl())?key=TestApiKey&radius=150&types=restaurant&location=\(location.latitude),\(location.longitude)"
        dispatchResponseToGetRequest(url: absoluteUrl, fileName: "nearby-success")
        sut = PlacesWorker(url: absoluteUrl)
        let expectation = XCTestExpectation(description: "testGivenValidInputWhenGetNearbyThenReturnSuccess")
        try sut!.run(params: location, resolve: { (worker, result) in
            XCTAssertNotNil(result)
            let result:Array<Place> = result as! Array<Place>
            XCTAssertEqual(result.count, 1)
            let place = result.first!
            XCTAssertEqual("Sporting Club Casino", place.name)
            XCTAssertEqual("dc84f07c660e036c7bb3608beaabd5b5ae962dce", place.id)
            XCTAssertEqual("https://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png", place.icon)
            XCTAssertEqual(true, place.openNow)
            XCTAssertEqual("ChIJLVzReX58Lg0RhwN-s_SrBY4", place.placeId)
            XCTAssertEqual(4, place.rating)
            XCTAssertEqual(43.3690192, place.location.latitude)
            XCTAssertEqual(-8.401833199999999, place.location.longitude)
            expectation.fulfill()
        }, reject: { (worker, error) in
            XCTFail("testGivenValidInputWhenGetNearbyThenReturnSuccess rejected")
        })
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    func testGivenInvalidInputWhenGetNearbyThenReturnNoPlaces() throws {
        let location = Location(latitude: 43.0, longitude: -8)
        let absoluteUrl = "\(serverUrl())?key=TestApiKey&radius=150&types=restaurant&location=\(location.latitude),\(location.longitude)"
        dispatchResponseToGetRequest(url: absoluteUrl, fileName: "nearby-success-noplaces")
        let expectation = XCTestExpectation(description: "testGivenValidInputWhenGetNearbyThenReturnSuccess")
        sut = PlacesWorker(url: absoluteUrl)
        try sut!.run(params: location, resolve: { (worker, result) in
            XCTFail("testGivenInvalidInputWhenGetNearbyThenReturnNoPlaces resolved")
            expectation.fulfill()
        }, reject: { (worker, error) in
            if case PlacesError.noPlaces = error {
                //ok
            }else{
                XCTFail("testGivenInvalidInputWhenGetNearbyThenReturnNoPlaces, expected: PlacesError.noPlaces actual:\(String(describing: error.self))")
            }
            expectation.fulfill()
        });
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
}
