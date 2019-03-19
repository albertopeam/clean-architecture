//
//  UVIndexWorkerTest.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 19/3/19.
//  Copyright © 2019 Alberto. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import CleanArchitecture

class UVIndexWorkerTest: XCTestCase {
    
    private lazy var url = "https://\(host)\(path)?lat={{lat}}&lon={{lon}}&appid=TestApiKey"
    private let host = "any"
    private let path = "/v1/uvi"
    private let location = Location(latitude: 37.75, longitude: -122.37)
    private var sut: UVIndexWorker!
    private lazy var params = [
        "lat": "\(location.latitude)",
        "lon": "\(location.longitude)",
        "appid": "TestApiKey"
    ]
    
    override func setUp() {
        super.setUp()
        sut = UVIndexWorker(url: url)
        OHHTTPStubs.onStubActivation { (request, stub, _) in
            print("** OHHTTPStubs: \(request.url!.absoluteString) stubbed by \(stub.name!). **")
        }
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testGivenSuccessServerWhenGetUVIndexThenMatchParseIsCorrect() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("uvindex-success.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }.name = "uvi success request"
        
        var result: UltravioletIndex?
        try sut.run(params: location, resolve: { (worker, res) in
            result = res as? UltravioletIndex
        }, reject: { (worker, error) in})
        
        expect(result).toNotEventually(beNil())
        let uvIndex = try result.unwrap()
        expect(uvIndex.uvIndex).toEventually(equal(10.06))
        expect(uvIndex.date).toEventually(equal("2017-06-26T12:00:00Z"))
        expect(uvIndex.timestamp).toEventually(equal(1498478400))
        expect(uvIndex.location.latitude).toEventually(equal(37.75))
        expect(uvIndex.location.longitude).toEventually(equal(-122.37))
    }
    
    func testGivenNetworkErrorWhenGetUVIndexThenMatchReject() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            let notConnectedError = NSError(domain: NSURLErrorDomain,
                                            code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                                            userInfo: nil)
            return OHHTTPStubsResponse(error: notConnectedError)
        }.name = "uvi error request"
        
        var error: UVIndexError?
        try sut.run(params: location, resolve: { (worker, result) in }, reject: { (worker, err) in
            error = err as? UVIndexError
        })
        
        expect(error).toNotEventually(beNil())
        expect(error).toEventually(equal(UVIndexError.other))
    }
}
