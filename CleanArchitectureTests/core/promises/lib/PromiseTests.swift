//
//  FutureTests.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 23/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

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
        sut.reject(with: Error.anError)
        expect(invoked).toEventually(beTrue())
    }
    
    func test_given_empty_promises_when_observe_multiple_then_reject_call_observers() {
        var invoked: [Bool?] = [nil, nil]
        for (index, _) in invoked.enumerated() {
            sut.observe { (result) in
                invoked[index] = true
            }
        }
        sut.reject(with: Error.anError)
        for (index, _) in invoked.enumerated() {
            expect(invoked[index]).toEventually(beTrue())
        }
    }
    
    func test_given_success_when_resolve_then_match_success() {
        var invoked: Bool? = nil
        sut.observe { (result) in
            switch result {
            case .value:
                invoked = true
            case .error:
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
            case .value:
                break
            case .error:
                invoked = true
            }
        }
        sut.reject(with: Error.anError)
        expect(invoked).toEventually(beTrue())
    }
    
    func test_chained() {
        
    }
    
    func test_transformed() {
        
    }
    
}

private enum Error: Swift.Error {
    case anError
}
