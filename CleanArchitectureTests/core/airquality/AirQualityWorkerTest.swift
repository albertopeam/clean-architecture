//
//  AirQualityWorkerTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 17/3/19.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Nimble
@testable import CleanArchitecture

class AirQualityWorkerTest: XCTestCase {
    
    private lazy var url = "https://\(host)\(path)?coordinates={{lat}},{{lon}}&limit=1&parameter=no2&has_geo=true"
    private let host = "any"
    private let path = "/v1/measurements"
    private let location = Location(latitude: 43.0, longitude: -8.1)
    private var sut: AirQualityWorker!
    private lazy var params = [
        "coordinates": "\(location.latitude),\(location.longitude)",
        "limit": "1",
        "parameter": "no2",
        "has_geo": "true"
    ]
    
    override func setUp() {
        super.setUp()
        sut = AirQualityWorker(url: url)
        OHHTTPStubs.onStubActivation { (request, stub, _) in
            print("** OHHTTPStubs: \(request.url!.absoluteString) stubbed by \(stub.name!). **")
        }
    }
    
    override func tearDown() {
        OHHTTPStubs .removeAllStubs()
        super.tearDown()
    }

    func testGivenSuccessResponseWhenFetchThenMatchExpected() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("airquality-success.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }.name = "air quality success request"
        
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
    
    func testGivenNoNetworkWhenFetchThenMatchNoNetworkError() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            let notConnectedError = NSError(domain: NSURLErrorDomain,
                                            code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                                            userInfo: nil)
            return OHHTTPStubsResponse(error: notConnectedError)
        }.name = "air quality no network request"
        
        var result: AirQualityError?
        try sut.run(params: location, resolve: { (worker, res) in }) {
            (worker, error) in
            result = error as? AirQualityError
        }
        
        expect(result).toNotEventually(beNil())
        expect(result).to(equal(AirQualityError.noNetwork))
    }
    
}
