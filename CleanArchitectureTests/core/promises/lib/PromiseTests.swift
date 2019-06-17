//
//  FutureTests.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 23/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//
//https://swiftbysundell.com/posts/under-the-hood-of-futures-and-promises-in-swift

import XCTest
import Nimble
@testable import CleanArchitecture

class PromiseTests: XCTestCase {
    
    private var sut: Promise<Void>!
    
    override func setUp() {
        super.setUp()
        sut = Promise()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_given_empty_promise_when_observe_one_then_resolving_call_observer() {
        var invoked: Bool? = nil
        sut.observe { (result) in
            invoked = true
        }
        sut.resolve(with: ())
        expect(invoked).toEventually(beTrue())
    }
    
    func test_given_empty_promises_when_observe_multiple_then_resolving_call_observers() {
        var invoked: [Bool?] = [nil, nil]
        for (index, _) in invoked.enumerated() {
            sut.observe { (result) in
                invoked[index] = true
            }
        }
        sut.resolve(with: ())
        for (index, _) in invoked.enumerated() {
            expect(invoked[index]).toEventually(beTrue())
        }
    }
    
    func test_given_empty_promise_when_observe_one_then_reject_call_observer() {
        var invoked: Bool? = nil
        sut.observe { (result) in
            invoked = true
        }
        sut.reject(with: FakeError.anError)
        expect(invoked).toEventually(beTrue())
    }
    
    func test_given_empty_promises_when_observe_multiple_then_reject_call_observers() {
        var invoked: [Bool?] = [nil, nil]
        for (index, _) in invoked.enumerated() {
            sut.observe { (result) in
                invoked[index] = true
            }
        }
        sut.reject(with: FakeError.anError)
        for (index, _) in invoked.enumerated() {
            expect(invoked[index]).toEventually(beTrue())
        }
    }
    
    func test_given_success_when_resolve_then_match_success() {
        var invoked: Bool? = nil
        sut.observe { (result) in
            switch result {
            case .success:
                invoked = true
            case .failure:
                break
            }
        }
        sut.resolve(with: ())
        expect(invoked).toEventually(beTrue())
    }
    
    func test_given_error_when_resolve_then_match_error() {
        var invoked: Bool? = nil
        sut.observe { (result) in
            switch result {
            case .success:
                break
            case .failure:
                invoked = true
            }
        }
        sut.reject(with: FakeError.anError)
        expect(invoked).toEventually(beTrue())
    }
    
    func test_given_two_resolved_futures_when_chained_then_observe_resolved() {
        let sut = FakeSumFuture(current: 2)
        let sut1 = FakeSumFuture(current: 3)
        let initial = 0
        var sum: Int?
        sut.run(value: initial).chained { (result) -> Future<Int> in
            return sut1.run(value: result)
        }.observe { (result) in
            switch result {
            case .success(let value):
                sum = value
            case .failure:
                break
            }
        }
        expect(sum).toEventually(equal(initial+sut.current+sut1.current))
    }
    
    func test_given_two_futures_first_rejected_when_chained_then_observe_rejected_and_not_touch_second() {
        let sut = FakeFuture()
        let spy = SpyFuture()
        sut.resolveWith { $0.reject(with: FakeError.anError) }
        var errorResult: Error?
        
        sut.run().chained { (_) -> Future<Void> in
            return spy.run()
        }.observe { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errorResult = error
            }
        }
        
        expect(errorResult).toEventually(matchError(FakeError.anError))
        expect(spy.invoked).toEventually(beFalse())
    }
    
    func test_given_two_futures_second_throws_when_chained_then_observe_rejected() {
        let sut = FakeFuture()
        sut.resolveWith { $0.resolve(with: ()) }
        var errorResult: Error?
        
        sut.run().chained { (_) -> Future<Void> in
            throw FakeError.anError
        }.observe { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errorResult = error
            }
        }
        
        expect(errorResult).toEventually(matchError(FakeError.anError))
    }
    
    func test_given_two_futures_second_rejected_when_chained_then_observe_rejected() {
        let sut = FakeFuture()
        let sut1 = FakeFuture()
        sut.resolveWith { $0.resolve(with: ()) }
        sut1.resolveWith { $0.reject(with: FakeError.anError) }
        var errorResult: Error?
        
        sut.run().chained { (_) -> Future<Void> in
            return sut1.run()
        }.observe { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errorResult = error
            }
        }
        
        expect(errorResult).toEventually(matchError(FakeError.anError))
    }
    
    func test_transformed() {
        let initial = 0
        let toSum = 1
        let sut = FakeMirrorFuture(current: initial)
        var sum: Int?
        
        sut.run().transformed { (input) -> Int in
            return input+toSum
        }.observe { (result) in
            switch result {
            case .success(let value):
                sum = value
            case .failure:
                break
            }
        }
        
        expect(sum).toEventually(equal(initial+toSum))
    }
    
    //TODO: maybe interesting add promises states
    
}

private enum FakeError: Error, Equatable {
    case anError
}

private final class FakeFuture {
    
    private var closure: ((Promise<Void>) -> Void)!
    
    func resolveWith(closure: @escaping (Promise<Void>) -> Void) {
        self.closure = closure
    }
    
    func run() -> Future<Void> {
        let promise = Promise<Void>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.closure(promise)
        }
        return promise
    }
    
}

private final class SpyFuture {
    
    var invoked = false
    
    func run() -> Future<Void> {
        invoked = true
        return Promise<Void>()
    }
}

private final class FakeSumFuture {
    
    let current: Int
    
    init(current: Int) {
        self.current = current
    }
    
    func run(value: Int) -> Future<Int> {
        let resolvedPromise = Promise<Int>(value: value+current)
        return resolvedPromise
    }
    
}

private final class FakeMirrorFuture {
    
    let current: Int
    
    init(current: Int) {
        self.current = current
    }
    
    func run() -> Future<Int> {
        let resolvedPromise = Promise<Int>(value: current)
        return resolvedPromise
    }
    
}
