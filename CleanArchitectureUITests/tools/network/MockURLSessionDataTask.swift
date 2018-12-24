//
//  MockURLSessionDataTask.swift
//  CleanArchitectureUITests
//
//  Created by Alberto on 24/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

//Sundell https://medium.com/@johnsundell/mocking-in-swift-56a913ee7484
class MockURLSessionDataTask: URLSessionDataTask {
    
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}
