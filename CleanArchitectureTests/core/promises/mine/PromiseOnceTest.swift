//
//  PromiseOnceTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 25/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

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
    
    func testGivenSuccessWorkerWhenPromiseOnceCompleteThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkWhenPromiseCompleteInvokeFinally")
        let params = "params"
        sut = PromiseOnce(worker: MockWorkers.Success(), params: params)
        sut!.then(finalizable: { (result) in
            XCTAssertEqual(params, result as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkerWhenPromiseOnceCompleteInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    func testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally")
        let params = "params"
        sut = PromiseOnce(worker:MockWorkers.Success(), params: params)
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssertEqual(params, any as! String)
            return PromiseOnce(worker:MockWorkers.Success(), params: params)
        }).then(finalizable: { (any) in
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    func testGivenErrorWorkWhenPromiseFailThenInvokeError() {
        let expectation = XCTestExpectation(description: "testGivenErrorWorkWhenPromiseFailThenInvokeError")
        sut = PromiseOnce(worker:MockWorkers.Reject(), params: nil)
        sut!.then{ (any) -> PromiseProtocol in
            XCTAssert(false, "testGivenErrorWorkWhenPromiseFailThenInvokeError invoked then")
            return PromiseOnce(worker: MockWorkers.NoAction())
        }.then { (any) in
            XCTAssert(false, "testGivenErrorWorkWhenPromiseFailThenInvokeError invoked finally")
        }.error { (error) in
            XCTAssertNotNil(error)
            let theError = error as NSError
            XCTAssertEqual(theError.domain, "MockWorkers.Reject")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    
    func testGivenWorkThatInvokeTwiceFinallyWhenPromiseCompleteThenInvokeFinallyOnce(){
        let expectation = XCTestExpectation(description: "testGivenWorkThatInvokeTwiceFinallyWhenPromiseCompleteThenInvokeFinallyOnce")
        let params = "params"
        sut = PromiseOnce(worker:MockWorkers.SuccessTwice(), params: params)
        var times = 0
        sut!.then(finalizable: { (any) in
            times += 1
            if (times == 2){
                XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseCompleteThenInvokeFinallyOnce invoked twice")
            }
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseCompleteThenInvokeFinallyOnce throw an error")
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    func testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce(){
        let expectation = XCTestExpectation(description: "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce")
        sut = PromiseOnce(worker:MockWorkers.RejectTwice(), params: nil)
        var times = 0
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce invoked then")
            return PromiseOnce(worker: MockWorkers.NoAction())
        }).then { (any) in
            XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce invoked finally")
        }.error { (error) in
            times += 1
            if (times == 2){
                XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce invoked twice")
            }
            XCTAssertNotNil(error)
            let theError = error as NSError
            XCTAssertEqual(theError.domain, "MockWorkers.Reject")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    func testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError(){
        let expectation = XCTestExpectation(description: "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError")
        sut = PromiseOnce(worker:MockWorkers.Throw())
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssert(false, "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError invoked then")
            return PromiseOnce(worker: MockWorkers.NoAction())
        }).then { (any) in
            XCTAssert(false, "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError invoked finally")
        }.error { (error) in
            let throwed = error as NSError
            XCTAssertEqual("MockWorkers.Throw", throwed.domain)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
    
    func testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteInvokeFinally")
        let params = "params"
        sut = PromiseOnce(worker:MockWorkers.Success(), params: params)
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssertEqual(params, any as! String)
            return PromiseOnce(worker:MockWorkers.Success(), params: params)
        }).then(completable: { (any) -> PromiseProtocol in
            XCTAssertEqual(params, any as! String)
            return PromiseOnce(worker:MockWorkers.Success(), params: params)
        }).then(finalizable: { (any) in
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: TestConstants.timeout)
    }
}
