//
//  Await.swift
//  CleanArchitecture
//
//  Created by Alberto on 24/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

func await(promise:PromiseProtocol) throws -> Any {
    var result: Any?
    var error: Error?
    let semaphore = DispatchSemaphore(value: 0)
    promise.then(finalizable: { (res) in
        result = res
        semaphore.signal()
    }).error(rejectable: { (err) in
        error = err
        semaphore.signal()
    })
    _ = semaphore.wait(timeout: .distantFuture)
    guard let unwrappedResult = result else {
        throw error!
    }
    return unwrappedResult
}
