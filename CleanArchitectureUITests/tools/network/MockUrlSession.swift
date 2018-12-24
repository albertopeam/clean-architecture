//
//  MockUrlSession.swift
//  CleanArchitectureUITests
//
//  Created by Alberto on 24/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

//Sundell https://medium.com/@johnsundell/mocking-in-swift-56a913ee7484
class MockURLSession: URLSession {
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var error: Error?
    var response: URLResponse = DummyURLResponse()
    
    init(data: Data) {
        self.data = data
    }
    
    init(error: Error) {
        self.error = error
    }
    
    override func dataTask(with url: URL,
                           completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        let response = self.response
        return MockURLSessionDataTask {
            completionHandler(data, response, error)
        }
    }
    
}

private final class DummyURLResponse: URLResponse {
    init() {
        super.init(url: URL(string: "https://www.google.es")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
