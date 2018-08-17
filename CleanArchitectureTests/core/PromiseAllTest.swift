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
    
    //chain of doubles with two completables
    func testGivenSuccessWorkersWhenTwoPromisesCompletesThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkersWhenTwoPromisesCompletesThenInvokeFinally")
        let params = "params"
        sut = PromiseAll(workers: [MockWorkers.Success(), MockWorkers.Success()], params: params)
        sut!.then(completable: { (result) -> PromiseProtocol in
            let results:Array<String> = result as! Array<String>
            XCTAssertEqual(results.count, 2)
            for item in results {
                XCTAssertEqual(item, params)
            }
            return PromiseAll(workers: [MockWorkers.Success(), MockWorkers.Success()], params: params)
        }).then(completable: { (result) -> PromiseProtocol in
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
            XCTAssert(false, "testGivenSuccessWorkersWhenTwoPromisesCompletesThenInvokeFinally throw an error")
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
    func testGivenOneRejectWorkersWhenRejectsTwiceThenInvokeErrorOnlyOne() {
        let expectation = XCTestExpectation(description: "testGivenOneRejectWorkersWhenRejectsTwiceThenInvokeErrorOnlyOne")
        var times = 0
        sut = PromiseAll(workers:[MockWorkers.RejectTwice()], params: nil)
        sut!.then { (any) in
            XCTAssert(false, "testGivenOneRejectWorkersWhenRejectsTwiceThenInvokeErrorOnlyOne invoked finally")
        }.error { (error) in
            times += 1
            if (times == 2){
                XCTAssert(false, "testGivenOneRejectWorkersWhenRejectsTwiceThenInvokeErrorOnlyOne invoked error twice")
            }
            XCTAssertNotNil(error)
            let theError = error as NSError
            XCTAssertEqual(theError.domain, "MockWorkers.Reject")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    //chain with two success workers that invokes twice success
    func testGivenTwoSuccessWorkersWhenSuccessTwiceThenInvokeErrorOnlyOne() {
        let expectation = XCTestExpectation(description: "testGivenTwoSuccessWorkersWhenSuccessTwiceThenInvokeErrorOnlyOne")
        var times = 0
        sut = PromiseAll(workers:[MockWorkers.SuccessTwice(), MockWorkers.SuccessTwice()], params: "params")
        sut!.then(finalizable: { (any) in
            times += 1
            if (times > 1){
                XCTAssert(false, "testGivenTwoSuccessWorkersWhenSuccessTwiceThenInvokeErrorOnlyOne invoked finally twice")
            }
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenTwoSuccessWorkersWhenSuccessTwiceThenInvokeErrorOnlyOne invoked error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    //worker that throws
    func testGivenWorkersThatThrowsWhenStartThenInvokeError(){
        let expectation = XCTestExpectation(description: "testGivenWorkersThatThrowsWhenStartThenInvokeError")
        var times = 0
        sut = PromiseAll(workers:[MockWorkers.Throw(), MockWorkers.Throw()])
        sut!.then { (any) in
            XCTAssert(false, "testGivenWorkersThatThrowsWhenStartThenInvokeError invoked finally")
        }.error { (error) in
            times += 1
            if (times > 1){
                XCTAssert(false, "testGivenWorkersThatThrowsWhenStartThenInvokeError invoked finally twice")
            }
            let throwed = error as NSError
            XCTAssertEqual("MockWorkers.Throw", throwed.domain)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

}
