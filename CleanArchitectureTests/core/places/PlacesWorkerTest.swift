//
//  PlacesGatewayTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 19/3/19.
//  Copyright © 2019 Alberto. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import CleanArchitecture

class PlacesWorkerTest: XCTestCase {
    
    private var sut: PlacesWorker!
    private lazy var url = "https://\(host)\(path)?key=TestApiKey&radius=150&types=restaurant&location={{location}}"
    private let host = "any"
    private let path = "/nearby"
    private let location = Location(latitude: 43.0, longitude: -8)
    private lazy var params = [
        "key": "TestApiKey",
        "radius": "150",
        "types": "restaurant",
        "location": "\(location.latitude),\(location.longitude)",
    ]
    
    override func setUp(){
        super.setUp()
        sut = PlacesWorker(url: url)
        OHHTTPStubs.onStubActivation { (request, stub, _) in
            print("** OHHTTPStubs: \(request.url!.absoluteString) stubbed by \(stub.name!). **")
        }
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        sut = nil
        super.tearDown()
    }
    
    func testGivenValidInputWhenGetNearbyThenReturnSuccess() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("nearby-success.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }.name = "nearby success request"
        
        var result: Array<Place>?
        try sut.run(params: location, resolve: { (worker, res) in
            result = res as? Array<Place>
        }, reject: { (worker, error) in })
        
        expect(result).toEventuallyNot(beNil())
        let places: Array<Place> = try result.unwrap()
        expect(places).toEventually(haveCount(1))
        let place = try places.first.unwrap()
        expect(place.name).toEventually(equal("Sporting Club Casino"))
        expect(place.id).toEventually(equal("dc84f07c660e036c7bb3608beaabd5b5ae962dce"))
        expect(place.icon).toEventually(equal("https://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png"))
        expect(place.openNow).toEventually(equal(true))
        expect(place.placeId).toEventually(equal("ChIJLVzReX58Lg0RhwN-s_SrBY4"))
        expect(place.rating).toEventually(equal(4))
        expect(place.location.latitude).toEventually(equal(43.3690192))
        expect(place.location.longitude).toEventually(equal(-8.401833199999999))
    }
    
    func testGivenInvalidInputWhenGetNearbyThenReturnNoPlaces() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("nearby-success-noplaces.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }.name = "nearby empty results request"
        
        var result: PlacesError?
        try sut.run(params: location, resolve: { (worker, result) in }, reject: { (worker, error) in
            result = error as? PlacesError
        });
        
        expect(result).toEventuallyNot(beNil())
        expect(result).toEventually(equal(PlacesError.noPlaces))
    }
}
