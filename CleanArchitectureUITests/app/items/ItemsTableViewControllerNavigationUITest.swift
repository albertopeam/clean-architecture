//
//  ItemsTableViewControllerUINavigationTest.swift
//  CleanArchitectureUITests
//
//  Created by Penas Amor, Alberto on 23/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class ItemsTableViewControllerNavigationUITest: XCTestCase {
    
    private var testTool = UITestNavigationTool<ItemsTableViewController>()
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
    
    func testGivenViewDidLoadWhenTapCellsThenNavigateToViewController() {
        for row in 0 ... sut.items.count-1 {
            let indexPath = IndexPath(row: row, section: 0)
            sut.tableview!.selectRow(at:indexPath , animated: false, scrollPosition: .none)
            sut.tableView(sut.tableview!, didSelectRowAt: indexPath)
            let navigation = testTool.navigationController!
            let vcs = navigation.controllers
            XCTAssertEqual(vcs.count, 2)
            if type(of: vcs[1]) != type(of: sut.items[row].target) {
                XCTFail("ViewController is not the expected type")
            }
            _ = navigation.popViewController(animated: false)
        }
    }
}
