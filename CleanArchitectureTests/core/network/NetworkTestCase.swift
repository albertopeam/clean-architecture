//
//  NetworkTestCase.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import XCTest
import Swifter

class NetworkTestCase: XCTestCase {
    
    private var mockServer:HttpServer?
    
    override func setUp() {
        super.setUp()
        mockServer = HttpServer()
        do {
            try mockServer!.start()
            //TODO: HttpServer has a start method who accepts a QUEUE, check if we can use the test thread QUEUE and avoid the use of expectations
        } catch {
            XCTFail("Mock HttpServer couldn't start")
        }
    }
    
    override func tearDown() {
        mockServer!.stop()
        mockServer = nil
        super.tearDown()
    }
    
    func dispatchResponseToGetRequest(statusCode:Int = 200, status:String = "OK", url:String, fileName:String) {
        let relativeUrl = url.replacingOccurrences(of: serverUrl(), with: "")
        mockServer![relativeUrl] = { r in
            return HttpResponse.raw(statusCode, status, ["Content-Type": "application/json"], { (writter:HttpResponseBodyWriter) in
                let testBundle = Bundle(for: type(of: self))
                XCTAssertNotNil(testBundle)
                let fileURL = testBundle.url(forResource: fileName, withExtension: "json")
                XCTAssertNotNil(fileURL)
                let data:NSData = try NSData(contentsOf: fileURL!)
                XCTAssertNotNil(data)
                try writter.write(data)
            })
        }
    }
    
    func dispatchErrorResponseToGetRequest(statusCode:Int, status:String, url:String) {
        let relativeUrl = url.replacingOccurrences(of: serverUrl(), with: "")
        mockServer![relativeUrl] = { r in
            return HttpResponse.raw(statusCode, status, ["Content-Type": "application/json"], nil)
            //TODO: add if needed to handle body!!!
//            return HttpResponse.raw(400, "Bad Request", ["Content-Type": "application/json"], { (writter:HttpResponseBodyWriter) in
//                let testBundle = Bundle(for: type(of: self))
//                XCTAssertNotNil(testBundle)
//                let fileURL = testBundle.url(forResource: fileName, withExtension: "json")
//                XCTAssertNotNil(fileURL)
//                let data:NSData = try NSData(contentsOf: fileURL!)
//                XCTAssertNotNil(data)
//                try writter.write(data)
//            })
        }
    }
    
    func serverUrl() -> String {
        return "http://localhost:8080/"
    }

}
