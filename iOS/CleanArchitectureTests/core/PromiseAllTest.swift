//
//  PromiseAllTest.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 25/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class PromiseAllTest: XCTestCase {
    
    var sut:PromiseAll?
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    //single success
    func testGivenSuccessWorkerWhenPromiseAllCompleteWorkerThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkerWhenPromiseAllCompleteWorkerThenInvokeFinally")
        let params = "params"
        sut = PromiseAll(workers: [MockWorkers.Success()], params: params)
        sut!.then(finalizable: { (result) in
            let results:Array<String> = result as! Array<String>
            XCTAssertEqual(results.count, 1)
            for item in results {
                XCTAssertEqual(item, params)
            }
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkerWhenPromiseAllCompleteWorkerThenInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    //double success
    func testGivenSuccessWorkersWhenPromiseAllCompletesWorkersThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkersWhenPromiseAllCompletesWorkersThenInvokeFinally")
        let params = "params"
        sut = PromiseAll(workers: [MockWorkers.Success(), MockWorkers.Success()], params: params)
        sut!.then(finalizable: { (result) in
            let results:Array<String> = result as! Array<String>
            XCTAssertEqual(results.count, 2)
            for item in results {
                XCTAssertEqual(item, params)
            }
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkersWhenPromiseAllCompletesWorkersThenInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    //chain of doubles
    func testGivenSuccessWorkersWhenPromisesCompletesThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkersWhenPromisesCompletesThenInvokeFinally")
        let params = "params"
        sut = PromiseAll(workers: [MockWorkers.Success(), MockWorkers.Success()], params: params)
        sut!.then(completable: { (result) -> PromiseProtocol in
            let results:Array<String> = result as! Array<String>
            XCTAssertEqual(results.count, 2)
            for item in results {
                XCTAssertEqual(item, params)
            }
            return PromiseAll(workers: [MockWorkers.Success(), MockWorkers.Success()], params: params)
        }).then(finalizable: { (result) in
            let results:Array<String> = result as! Array<String>
            XCTAssertEqual(results.count, 2)
            for item in results {
                XCTAssertEqual(item, params)
            }
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkersWhenPromisesCompletesThenInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    //chain with one rejectable
    func testGivenOneSuccessAndOneRejectWorkerkWhenRejectedThenInvokeError() {
        let expectation = XCTestExpectation(description: "testGivenOneSuccessAndOneRejectWorkerkWhenRejectedThenInvokeError")
        let params = NSError(domain: "error", code: 0)
        sut = PromiseAll(workers:[MockWorkers.Success(), MockWorkers.Reject()], params: params)
        sut!.then { (any) in
            XCTAssert(false, "testGivenOneSuccessAndOneRejectWorkerkWhenRejectedThenInvokeError invoked finally")
        }.error { (error) in
            XCTAssertNotNil(error)
            let theError = error as NSError
            XCTAssertEqual(theError.domain, "MockWorkers.Reject")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    //chain with one rejectable worker that invokes twice reject
    func testGivenOneRejectWorkerkWhenRejecttsTwiceThenInvokeErrorOnlyOne() {
        let expectation = XCTestExpectation(description: "testGivenOneRejectWorkerkWhenRejecttsTwiceThenInvokeErrorOnlyOne")
        var times = 0
        sut = PromiseAll(workers:[MockWorkers.RejectTwice()], params: nil)
        sut!.then { (any) in
            XCTAssert(false, "testGivenOneRejectWorkerkWhenRejecttsTwiceThenInvokeErrorOnlyOne invoked finally")
        }.error { (error) in
            times += 1
            if (times == 2){
                XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseCompleteThenInvokeFinallyOnce invoked twice")
            }
            XCTAssertNotNil(error)
            let theError = error as NSError
            XCTAssertEqual(theError.domain, "MockWorkers.Reject")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    //todo: replace mock workers in promise once by MockeWorkers class
    //todo: faltan los 3 últimos, de todas formas anan;izar cobertura y ver si faltan casos. IGUAL NO HACE FALTA Más
}
