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
        sut = PromiseOnce(worker: MockSuccessFinallyWork(), params: params)
        sut!.then(finalizable: { (result) in
            XCTAssertEqual(params, result as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkerWhenPromiseOnceCompleteInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally")
        let params = "params"
        sut = PromiseOnce(worker:MockSuccessFinallyWork(), params: params)
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssertEqual(params, any as! String)
            return PromiseOnce(worker:MockSuccessFinallyWork(), params: params)
        }).then(finalizable: { (any) in
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenErrorWorkWhenPromiseFailThenInvokeError() {
        let expectation = XCTestExpectation(description: "testGivenErrorWorkWhenPromiseFailThenInvokeError")
        let params = NSError(domain: "error", code: 0)
        sut = PromiseOnce(worker:MockErrorWork(), params: params)
        sut!.then{ (any) -> PromiseProtocol in
            XCTAssert(false, "testGivenErrorWorkWhenPromiseFailThenInvokeError invoked then")
            return PromiseOnce(worker: MockNonResolvableWork())
        }.then { (any) in
            XCTAssert(false, "testGivenErrorWorkWhenPromiseFailThenInvokeError invoked finally")
        }.error { (error) in
            XCTAssertEqual(params, error as NSError)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    
    func testGivenWorkThatInvokeTwiceFinallyWhenPromiseCompleteThenInvokeFinallyOnce(){
        let expectation = XCTestExpectation(description: "testGivenWorkThatInvokeTwiceFinallyWhenPromiseCompleteThenInvokeFinallyOnce")
        let params = "params"
        sut = PromiseOnce(worker:MockSuccessTwiceFinallyWork(), params: params)
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
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce(){
        let expectation = XCTestExpectation(description: "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce")
        let params = NSError(domain: "error", code: 0)
        sut = PromiseOnce(worker:MockErrorTwiceWork(), params: params)
        var times = 0
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce invoked then")
            return PromiseOnce(worker: MockNonResolvableWork())
        }).then { (any) in
            XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce invoked finally")
        }.error { (error) in
            times += 1
            if (times == 2){
                XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce invoked twice")
            }
            XCTAssertEqual(params, error as NSError)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError(){
        let expectation = XCTestExpectation(description: "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError")
        sut = PromiseOnce(worker:MockThrowWhileRunningWork())
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssert(false, "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError invoked then")
            return PromiseOnce(worker: MockNonResolvableWork())
        }).then { (any) in
            XCTAssert(false, "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError invoked finally")
        }.error { (error) in
            let throwed = error as NSError
            XCTAssertEqual("MockThrowWhileRunningWork", throwed.domain)
            XCTAssertEqual(0, throwed.code)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteInvokeFinally")
        let params = "params"
        sut = PromiseOnce(worker:MockSuccessFinallyWork(), params: params)
        sut!.then(completable: { (any) -> PromiseProtocol in
            XCTAssertEqual(params, any as! String)
            return PromiseOnce(worker:MockSuccessFinallyWork(), params: params)
        }).then(completable: { (any) -> PromiseProtocol in
            XCTAssertEqual(params, any as! String)
            return PromiseOnce(worker:MockSuccessFinallyWork(), params: params)
        }).then(finalizable: { (any) in
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
}

private class MockSuccessFinallyWork:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        resolve(self, params!)
    }
}

private class MockSuccessTwiceFinallyWork:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        resolve(self, params!)
        resolve(self, params!)
    }
}

private class MockErrorTwiceWork:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        reject(self, params! as! Error)
        reject(self, params! as! Error)
    }
}

private class MockErrorWork:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        reject(self, params! as! Error)
    }
}

private class MockNonResolvableWork:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {}
}

private class MockThrowWhileRunningWork:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        throw NSError(domain: "MockThrowWhileRunningWork", code: 0, userInfo: nil)
    }
}
