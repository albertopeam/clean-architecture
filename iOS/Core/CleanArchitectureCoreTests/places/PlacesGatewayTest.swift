//
//  PlacesGatewayTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 7/5/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import Swifter
@testable import CleanArchitectureCore

class PlacesGatewayTest: XCTestCase {
    
    var mockServer:HttpServer?
    var sut:PlacesGateway?
    let apiKey = "TESTApiKey"
    
    override func setUp(){
        super.setUp()
        continueAfterFailure = false
        mockServer = HttpServer()
        do {
            try mockServer!.start()
            //TODO: HttpServer has a start method who accepts a QUEUE, check if we can use the test thread QUEUE and avoid the use of expectations
        } catch {
            XCTFail("Mock HttpServer couldn't start")
        }
    }
    
    override func tearDown() {
        mockServer!.stop()
        mockServer = nil
        sut = nil
        super.tearDown()
    }
    
    func testGivenValidInputWhenGetNearbyThenReturnSuccess() throws {
        let location = Location(latitude: 43.0, longitude: -8)
        let absoluteUrl = "http://localhost:8080/?key=TestApiKey&radius=150&types=restaurant&location=\(location.latitude),\(location.longitude)"
        let relativeUrl = absoluteUrl.replacingOccurrences(of: "http://localhost:8080", with: "")
        mockServer![relativeUrl] = { r in     
            return HttpResponse.raw(200, "OK", ["Content-Type": "application/json"], { (writter:HttpResponseBodyWriter) in
                let testBundle = Bundle(for: type(of: self))
                XCTAssertNotNil(testBundle)
                let fileURL = testBundle.url(forResource: "nearby-success", withExtension: "json")
                XCTAssertNotNil(fileURL)
                let data:NSData = try NSData(contentsOf: fileURL!)
                XCTAssertNotNil(data)
                try writter.write(data)
            })
        }
        let expectation = XCTestExpectation(description: "testGivenValidInputWhenGetNearbyThenReturnSuccess")
        sut = PlacesGateway(url: absoluteUrl)
        try sut!.run(params: location, resolve: { (places) in
            XCTAssertNotNil(places)
            let result:Array<Place> = places as! Array<Place>
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
        }, reject: { (error) in
            XCTFail("testGivenValidInputWhenGetNearbyThenReturnSuccess rejected")
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testGivenInvalidInputWhenGetNearbyThenReturnNoPlaces() throws {
        let location = Location(latitude: 43.0, longitude: -8)
        let absoluteUrl = "http://localhost:8080/?key=TestApiKey&radius=150&types=restaurant&location=\(location.latitude),\(location.longitude)"
        let relativeUrl = absoluteUrl.replacingOccurrences(of: "http://localhost:8080", with: "")
        mockServer![relativeUrl] = { r in
            return HttpResponse.raw(200, "OK", ["Content-Type": "application/json"], { (writter:HttpResponseBodyWriter) in
                let testBundle = Bundle(for: type(of: self))
                XCTAssertNotNil(testBundle)
                let fileURL = testBundle.url(forResource: "nearby-success-noplaces", withExtension: "json")
                XCTAssertNotNil(fileURL)
                let data:NSData = try NSData(contentsOf: fileURL!)
                XCTAssertNotNil(data)
                try writter.write(data)
            })
        }
        let expectation = XCTestExpectation(description: "testGivenValidInputWhenGetNearbyThenReturnSuccess")
        sut = PlacesGateway(url: absoluteUrl)
        try sut!.run(params: location, resolve: { (places) in
            XCTFail("testGivenInvalidInputWhenGetNearbyThenReturnNoPlaces resolved")
            expectation.fulfill()
        }, reject: { (error) in
            if case PlacesError.noPlaces = error {
                //ok
            }else{
                XCTFail("testGivenInvalidInputWhenGetNearbyThenReturnNoPlaces, expected: PlacesError.noPlaces actual:\(String(describing: error.self))")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
}
