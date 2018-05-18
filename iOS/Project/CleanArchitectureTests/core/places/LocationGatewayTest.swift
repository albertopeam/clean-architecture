//
//  LocationGatewayTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 8/5/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import CoreLocation
@testable import CleanArchitecture

class LocationGatewayTest: XCTestCase {
    
    private var sut:LocationGateway?
    private var mockLocationManager:MockLocationManager?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        mockLocationManager = MockLocationManager()
    }
    
    override func tearDown() {
        sut = nil
        mockLocationManager = nil
        super.tearDown()
    }
    
    func testGivenLocationAvailableWhenStartThenReceiveLocation() throws {
        let expectation = XCTestExpectation(description: "testGivenLocationAvailableWhenStartThenReceiveLocation")
        mockLocationManager!.mockedStatus = .authorizedWhenInUse
        mockLocationManager!.result = CLLocation(latitude: 43.0, longitude: -8.0)
        sut = LocationGateway(locationManager: mockLocationManager!)
        try sut!.run(params: nil, resolve: { (location) in
            let result = location as! Location
            XCTAssertEqual(result.latitude, 43.0)
            XCTAssertEqual(result.longitude, -8.0)
            expectation.fulfill()
        }) { (error) in
            XCTFail("testGivenLocationAvailableWhenStartThenReceiveLocation rejected")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenNoLocationPermissionWhenStartThenReceiveError() throws {
        let expectation = XCTestExpectation(description: "testGivenNoLocationPermissionWhenStartThenReceiveError")
        mockLocationManager!.mockedStatus = .notDetermined        
        sut = LocationGateway(locationManager: mockLocationManager!)
        try sut!.run(params: nil, resolve: { (location) in
            XCTFail("testGivenNoLocationPermissionWhenStartThenReceiveError rejected")
        }) { (error) in
            if case LocationError.noLocationPermission = error {
                //ok
            }else{
                XCTFail("testGivenNoLocationPermissionWhenStartThenReceiveError, expected: LocationError.noLocationPermission actual:\(String(describing: error.self))")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenNoLocationWhenStartThenReceiveError() throws {
        let expectation = XCTestExpectation(description: "testGivenNoLocationWhenStartThenReceiveError")
        mockLocationManager!.mockedStatus = .authorizedWhenInUse
        mockLocationManager!.result = NSError(domain: "kCLErrorDomain", code: 0, userInfo: nil)
        sut = LocationGateway(locationManager: mockLocationManager!)
        try sut!.run(params: nil, resolve: { (location) in
            XCTFail("testGivenNoLocationWhenStartThenReceiveError rejected")
        }) { (error) in
            if case LocationError.noLocation = error {
                //ok
            }else{
                XCTFail("testGivenNoLocationWhenStartThenReceiveError, expected: LocationError.noLocation actual:\(String(describing: error.self))")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    class MockLocationManager: LocationManager {
        
        var mockedStatus:CLAuthorizationStatus?
        var result:Any?
        
        override func authorizationStatus() -> CLAuthorizationStatus {
            if let status:CLAuthorizationStatus = mockedStatus {
                return status
            }else{
                return super.authorizationStatus()
            }
        }
        
        override func startUpdatingLocation() {
            if let location = result as? CLLocation {
                delegate?.locationManager!(self, didUpdateLocations: [location])
            }else if let error = result as? NSError {
                delegate?.locationManager!(self, didFailWithError: error)
            }else{
                assertionFailure("startUpdatingLocation invoked without result, please inject a CLLocation or NSError to MockLocationManager")
            }
        }
    }
    
}
