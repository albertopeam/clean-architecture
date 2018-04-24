//
//  CleanArchitectureTests.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class PromiseTest: XCTestCase {
    
    var sut:Promise?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testGivenSuccessWorkWhenFinallyThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "givenSuccessWorkWhenFinallyThenInvokeFinally")
        let params = "params"
        sut = Promise(work:MockSuccessFinallyWork(), params: params)
        sut!.finally { (any) in
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }.error { (error) in
            XCTAssert(false, "givenSuccessWorkWhenFinallyThenInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }

}

private class MockSuccessFinallyWork:Work{
    func run(params: Any?, resolve: @escaping Resolve, reject: @escaping Reject) throws {
        resolve(params!)
    }
}

