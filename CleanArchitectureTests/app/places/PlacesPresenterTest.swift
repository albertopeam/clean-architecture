//
//  PlacesPresenterTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 23/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class PlacesPresenterTest: XCTestCase {
    
    private var sut:NearbyPlacesPresenter?
    private var vm:NearbyPlacesViewState?
    private var spyView:Spy.NearbyPlacesView?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        vm = NearbyPlacesViewState(places: nil, error: nil, requestPermission: false)
        spyView = Spy.NearbyPlacesView()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGivenSuccessEnvWhenGetNearbyPlacesThenVMhasPlaces() {
        sut = NearbyPlacesPresenter(places: Mock.SuccessPlaces(), viewModel: vm!, view: spyView!)
        sut?.nearbyPlaces()
        XCTAssertNotNil(spyView!.vm)
        let result = spyView!.vm!
        XCTAssertNil(result.error)
        XCTAssertFalse(result.requestPermission)
        XCTAssertNotNil(result.places)
        XCTAssertEqual(result.places!.count, 1)
        let place = result.places![0]
        XCTAssertEqual(place.id, "id")
        XCTAssertEqual(place.placeId, "placeId")
        XCTAssertEqual(place.icon, "icon")
        XCTAssertEqual(place.openNow, true)
        XCTAssertEqual(place.rating, 4.5)
        XCTAssertEqual(place.location.latitude, 43.0)
        XCTAssertEqual(place.location.longitude, -8.0)
    }
    
    func testGivenErrorEnvWhenGetNearbyPlacesThenVMHasErrorAndNoPlaces() {
        sut = NearbyPlacesPresenter(places: Mock.ErrorPlaces(), viewModel: vm!, view: spyView!)
        sut?.nearbyPlaces()
        XCTAssertNotNil(spyView!.vm)
        let result = spyView!.vm!
        XCTAssertNotNil(result.error)
        XCTAssertFalse(result.requestPermission)
        XCTAssertNil(result.places)
        let error = result.error!
        XCTAssertEqual(error, "Denied location usage")
    }
    
    func testGivenNoLocationPermissionEnvWhenGetNearbyPlacesThenVMHasErrorAndNoPlaces() {
        sut = NearbyPlacesPresenter(places: Mock.ErrorNoLocationPermissionPlaces(), viewModel: vm!, view: spyView!)
        sut?.nearbyPlaces()
        XCTAssertNotNil(spyView!.vm)
        let result = spyView!.vm!
        XCTAssertNil(result.error)
        XCTAssertTrue(result.requestPermission)
        XCTAssertNil(result.places)
    }
    
}


private class Mock{
    internal class SuccessPlaces:PlacesProtocol{
        func nearby(output: PlacesOutputProtocol) {
            let place = Place(id: "id", placeId: "placeId", name: "name", icon: "icon", openNow: true, rating: 4.5, location: Location(latitude: 43.0, longitude: -8.0))
            output.onNearby(places: [place])
        }
    }
    
    internal class ErrorPlaces:PlacesProtocol{
        func nearby(output: PlacesOutputProtocol) {
            output.onNearbyError(error: LocationError.deniedLocationUsage)
        }
    }
    
    internal class ErrorNoLocationPermissionPlaces:PlacesProtocol{
        func nearby(output: PlacesOutputProtocol) {
            output.onNearbyError(error: LocationError.noLocationPermission)
        }
    }
}

private class Spy {
    internal class NearbyPlacesView:NearbyPlacesViewProtocol {
        
        var vm:NearbyPlacesViewState?
        
        func newState(viewModel: NearbyPlacesViewState) {
            self.vm = viewModel
        }
        
    }
}
