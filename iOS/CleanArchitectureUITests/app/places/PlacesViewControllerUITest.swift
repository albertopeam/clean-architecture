//
//  PlacesViewControllerUITest.swift
//  CleanArchitectureUITests
//
//  Created by Penas Amor, Alberto on 23/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import CoreLocation
@testable import CleanArchitecture

class PlacesViewControllerUITest: XCTestCase {
    
    private var testTool = UITestNavigationTool<NearbyPlacesViewController>()
    private var sut:NearbyPlacesViewController?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        testTool.tearDown()
        super.tearDown()
    }
    
    func testGivenSuccessEnvWhenGetNearbyThenPlacesAreInMap() {
        let presenter = Mock.PlacesPresenter()
        let place = Place(id: "id", placeId: "placeId", name: "name", icon: "icon", openNow: true, rating: 4.5, location: Location(latitude: 43.0, longitude: -8.0))
        let places = [place]
        presenter.vm = NearbyPlacesViewModel(places: places, error: nil, requestPermission: false)
        sut = NearbyPlacesViewController(presenter: presenter, locationManager: Mock.LocationManager())
        presenter.view = sut!
        testTool.setUp(withViewController: sut!)
        let tableview = sut!.placesTableView!
        //tableview.register(UINib(nibName: "NearbyPlaceCell", bundle: nil), forCellReuseIdentifier: "nearby_place_cell")
        XCTAssertNotNil(tableview)
        XCTAssertEqual(tableview.numberOfSections, 1)
        XCTAssertEqual(tableview.numberOfRows(inSection: 0), places.count)
        for (index, element) in places.enumerated() {
            //TODO: crash in cast because the cell belongs to another target
            let cell:NearbyPlaceCell = tableview.cellForRow(at: IndexPath(row: index, section: 0)) as! NearbyPlaceCell
            XCTAssertEqual(cell.nameLabel.text, element.name)
            XCTAssertEqual(cell.ratingLabel.text, element.rating.description)
            XCTAssertEqual(cell.openLabel.text, element.openNow ? "OPEN":"!OPEN")
        }
    }
    
}

private class Mock {
    internal class PlacesPresenter:NearbyPlacesPresenterProtocol {
        
        var view:NearbyPlacesViewProtocol?
        var vm:NearbyPlacesViewModel?
        
        func nearbyPlaces() {
            view?.newState(viewModel: vm!)
        }
    }
    
    internal class LocationManager:CLLocationManager{}
}
