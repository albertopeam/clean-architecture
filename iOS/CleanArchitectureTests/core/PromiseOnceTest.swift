//
//  PromiseOnceTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 25/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest

class PromiseOnceTest: XCTestCase {
    
    var sut:PromiseOnce?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGivenSuccessWorkerWhenPromiseOnceCompleteInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkWhenPromiseCompleteInvokeFinally")
        let params = "params"
        sut = PromiseOnce(worker: MockSuccessFinallyWork(), params: params)
        sut!.then(finalizable: { (result) in
            XCTAssertEqual(params, result as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkerWhenPromiseOnceCompleteInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
}

private class MockSuccessFinallyWork:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        resolve(self, params!)
    }
}
