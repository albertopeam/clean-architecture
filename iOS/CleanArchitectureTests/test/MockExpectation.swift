//
//  MockExpectation.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import XCTest

class MockExpectation {
    let expectation:XCTestExpectation
    init(expectation:XCTestExpectation) {
        self.expectation = expectation
    }
}
