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
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGivenSuccessWorkWhenPromiseCompleteInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkWhenPromiseCompleteInvokeFinally")
        let params = "params"
        sut = Promise(work:MockSuccessFinallyWork(), params: params)
        sut!.then(finally: { (any) in
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorkWhenPromiseCompleteInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorkWhenPromisesCompleteThenInvokeFinally")
        let params = "params"
        sut = Promise(work:MockSuccessFinallyWork(), params: params)
        sut!.then(resolve: { (any) -> Promise in
            XCTAssertEqual(params, any as! String)
            return Promise(work:MockSuccessFinallyWork(), params: params)
        }).then(finally: { (any) in
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
        sut = Promise(work:MockErrorWork(), params: params)
        sut!.then{ (any) -> Promise in
            XCTAssert(false, "testGivenErrorWorkWhenPromiseFailThenInvokeError invoked then")
            return Promise(work: MockNonResolvableWork())
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
        sut = Promise(work:MockSuccessTwiceFinallyWork(), params: params)
        var times = 0
        sut!.then(finally: { (any) in
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
        sut = Promise(work:MockErrorTwiceWork(), params: params)
        var times = 0
        sut!.then{ (any) -> Promise in
            XCTAssert(false, "testGivenWorkThatInvokeTwiceFinallyWhenPromiseErrorThenInvokeErrorOnce invoked then")
            return Promise(work: MockNonResolvableWork())
        }.then { (any) in
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
        sut = Promise(work:MockThrowWhileRunningWork())
        sut!.then{ (any) -> Promise in
            XCTAssert(false, "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError invoked then")
            return Promise(work: MockNonResolvableWork())
        }.then { (any) in
            XCTAssert(false, "testGivenWorkThatThrowsWhenPromiseErrorThenInvokeError invoked finally")
        }.error { (error) in
            let throwed = error as NSError
            XCTAssertEqual("MockThrowWhileRunningWork", throwed.domain)
            XCTAssertEqual(0, throwed.code)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteInvokeFinally() {
        let expectation = XCTestExpectation(description: "testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteInvokeFinally")
        let params = "params"
        sut = Promise(work:MockSuccessFinallyWork(), params: params)
        sut!.then(resolve: { (any) -> Promise in
            XCTAssertEqual(params, any as! String)
            return Promise(work:MockSuccessFinallyWork(), params: params)
        }).then(resolve: { (any) -> Promise in
            XCTAssertEqual(params, any as! String)
            return Promise(work:MockSuccessFinallyWork(), params: params)
        }).then(finally: { (any) in
            XCTAssertEqual(params, any as! String)
            expectation.fulfill()
        }).error { (error) in
            XCTAssert(false, "testGivenSuccessWorksWhenChainTwoThensAndPromiseCompleteInvokeFinally throw an error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
}

private class MockSuccessFinallyWork:Work{
    func run(params: Any?, resolve: @escaping Resolve, reject: @escaping Reject) throws {
        resolve(params!)
    }
}

private class MockSuccessTwiceFinallyWork:Work{
    func run(params: Any?, resolve: @escaping Resolve, reject: @escaping Reject) throws {
        resolve(params!)
        resolve(params!)
    }
}

private class MockErrorTwiceWork:Work{
    func run(params: Any?, resolve: @escaping Resolve, reject: @escaping Reject) throws {
        reject(params! as! Error)
        reject(params! as! Error)
    }
}

private class MockErrorWork:Work{
    func run(params: Any?, resolve: @escaping Resolve, reject: @escaping Reject) throws {
        reject(params! as! Error)
    }
}

private class MockNonResolvableWork:Work{
    func run(params: Any?, resolve: @escaping Resolve, reject: @escaping Reject) throws {}
}

private class MockThrowWhileRunningWork:Work{
    func run(params: Any?, resolve: @escaping Resolve, reject: @escaping Reject) throws {
        throw NSError(domain: "MockThrowWhileRunningWork", code: 0, userInfo: nil)
    }
}



