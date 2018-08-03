//
//  UVIndexViewControllerTest.swift
//  CleanArchitectureUITests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest

class UVIndexViewControllerTest: XCTestCase {
    
    private var testTool = UITestNavigationTool<UVIndexViewController>()
    private var mockViewModel = Mock.UVIndexViewModel()
    private var sut:UVIndexViewController?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        testTool.tearDown()
        super.tearDown()
    }
    
    func testGivenSuccessWhenGetUVIndexThenMatchUI() {
        sut = UVIndexViewController(viewModel: mockViewModel)
        testTool.setUp(withViewController: sut!)
        XCTAssertFalse(sut!.activityIndicator.isHidden)
        XCTAssertTrue(sut!.errorView.isHidden)
        XCTAssertTrue(sut!.successView.isHidden)
        mockViewModel.viewStateObservable.value = .success
        mockViewModel.uvIndexObservable.value = "1.5"
        mockViewModel.uvIndexColorObservable.value = "Green"
        mockViewModel.descriptionObservable.value = "Low"
        mockViewModel.dateObservable.value = "fake date"
        mockViewModel.locationObservable.value = Location(latitude: 43.0, longitude: -8.0)
        mockViewModel.locationPermissionObservable.value = true
        XCTAssertTrue(sut!.activityIndicator.isHidden)
        XCTAssertTrue(sut!.errorView.isHidden)
        XCTAssertFalse(sut!.successView.isHidden)
        XCTAssertEqual(sut!.ultravioletIndexLabel.text, "1.5")
        XCTAssertEqual(sut!.descriptionLabel.text, "Low")
        XCTAssertEqual(sut!.dateLabel.text, "fake date")
        XCTAssertEqual(sut!.mapView.annotations.first?.coordinate.latitude, 43.0)
        XCTAssertEqual(sut!.mapView.annotations.first?.coordinate.longitude, -8.0)
    }
    
    func testGivenErrorWhenGetUVIndexThenMatchUI() {
        sut = UVIndexViewController(viewModel: mockViewModel)
        testTool.setUp(withViewController: sut!)
        XCTAssertFalse(sut!.activityIndicator.isHidden)
        XCTAssertTrue(sut!.errorView.isHidden)
        XCTAssertTrue(sut!.successView.isHidden)
        mockViewModel.viewStateObservable.value = .error
        mockViewModel.errorObservable.value = "an error"
        XCTAssertTrue(sut!.activityIndicator.isHidden)
        XCTAssertFalse(sut!.errorView.isHidden)
        XCTAssertTrue(sut!.successView.isHidden)
        XCTAssertEqual(sut!.errorMessageLabel.text, "an error")
    }
    
}

private class Mock {
    internal class UVIndexViewModel:UVIndexViewModelProtocol {
        var viewStateObservable: Observable<UVIndexViewState> = Observable<UVIndexViewState>(value: UVIndexViewState.loading)
        var uvIndexObservable: Observable<String> = Observable<String>(value: "")
        var uvIndexColorObservable: Observable<String> = Observable<String>(value: "Black")
        var descriptionObservable: Observable<String> = Observable<String>(value: "")
        var dateObservable: Observable<String> = Observable<String>(value: "")
        var locationObservable: Observable<Location> = Observable<Location>(value: Location(latitude:0, longitude:0))
        var locationPermissionObservable: Observable<Bool> = Observable<Bool>(value: true)
        var errorObservable: Observable<String> = Observable<String>(value: "")
        func loadUVIndex() {}
    }
}
