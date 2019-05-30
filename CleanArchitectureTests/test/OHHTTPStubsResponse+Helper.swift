//
//  OHHTTPStubsResponse+Init.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 21/03/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import Foundation
import OHHTTPStubs

extension OHHTTPStubsResponse {
    
    static func _200(jsonFileName: String, inBundleForClass: AnyClass) throws -> OHHTTPStubsResponse {
        guard let filePath = OHPathForFile(jsonFileName, inBundleForClass) else {
            throw Error.fileNotFound
        }
        return OHHTTPStubsResponse(fileAtPath: filePath,
                                   statusCode: 200,
                                   headers: ["Content-Type":"application/json"])
    }
    
    static func _400() -> OHHTTPStubsResponse {
        let BadRequest = NSError(domain: NSURLErrorDomain,
                                 code: 400,
                                 userInfo: ["NSLocalizedDescription": "Bad Request"])
        return OHHTTPStubsResponse(error: BadRequest)
    }
    
    enum Error: Swift.Error {
        case fileNotFound
    }
    
}
