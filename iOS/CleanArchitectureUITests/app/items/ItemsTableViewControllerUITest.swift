//
//  CleanArchitectureUITests.swift
//  CleanArchitectureUITests
//
//  Created by Penas Amor, Alberto on 20/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class ItemsTableViewControllerUITest: XCTestCase {
    
    private var testTool = UITestTool<ItemsTableViewController>()
    private var sut = ItemsTableViewController()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        testTool.setUp(withViewController: sut)
        XCTAssertNotNil(sut.view)
    }
    
    override func tearDown() {
        testTool.tearDown()
        super.tearDown()
    }
    
    func testGivenViewDidLoadThenMatchesModel() {
        let tableview = sut.tableview!
        let items = sut.items
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertNotNil(tableview)
        XCTAssertEqual(tableview.numberOfSections, 1)
        XCTAssertEqual(tableview.numberOfRows(inSection: 0), 2)
        for (index, element) in items.enumerated() {
            let cell = tableview.cellForRow(at: IndexPath(row: index, section: 0))
            XCTAssertEqual(cell?.textLabel?.text, element.name)
        }
    }
}
