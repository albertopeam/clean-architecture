//
//  WeatherViewControllerUITest.swift
//  CleanArchitectureUITests
//
//  Created by Alberto on 31/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class WeatherViewControllerUITest: XCTestCase {
    
    private var testTool = UITestNavigationTool<WeatherViewController>()
    private var sut:WeatherViewController?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        testTool.tearDown()
        super.tearDown()
    }
    
    func testGivenSuccessEnvWhenGetWeatherThenWeathersAreShown() {
        let presenter = Mock.WeatherPresenter()
        let weather = InstantWeather(name: "name", description: "description", icon: "icon", temp: 12.0, pressure: 1024, humidity: 75.0, windSpeed: 5.1, windDegrees: 30, datetime: 1)
        let weathers = [weather]
        presenter.vm = WeatherViewModel(loading: true, weathers: nil, error: nil)
        sut = WeatherViewController(presenter: presenter)
        presenter.view = sut!
        testTool.setUp(withViewController: sut!)
        XCTAssertFalse(sut!.activityIndicator.isHidden)
        presenter.vm = WeatherViewModel(loading: false, weathers: weathers, error: nil)
        presenter.weathers()
        let tableview = sut!.tableView!
        XCTAssertTrue(sut!.activityIndicator.isHidden)
        XCTAssertFalse(tableview.isHidden)
        XCTAssertNotNil(tableview)
        XCTAssertEqual(tableview.numberOfSections, 1)
        XCTAssertEqual(tableview.numberOfRows(inSection: 0), weathers.count)
        //TODO: crash in tableview.cellForRow cast(in NearbyPlacesViewController) because the cell belongs to another target
//        for (index, element) in weathers.enumerated() {
//            let cell:WeatherTableViewCell = tableview.cellForRow(at: IndexPath(row: index, section: 0)) as! WeatherTableViewCell
//            XCTAssertEqual(cell.cityLabel.text, element.name)
//        }
    }
}

private class Mock {
    internal class WeatherPresenter:WeatherPresenterProtocol {
        
        var view:WeatherViewProtocol?
        var vm:WeatherViewModel?
        
        func weathers() {
            view?.newState(viewModel: vm!)
        }
    }
}
