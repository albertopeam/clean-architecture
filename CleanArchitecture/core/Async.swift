//
//  Async.swift
//  CleanArchitecture
//
//  Created by Alberto on 24/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

//TODO: promises in main thread won't work. Please create a way to handle in a RunLoop or whatever,,, especial case is LocationManager.
import Foundation

public struct Queue {
    static let async = DispatchQueue(label: "com.github.albertopeam.async-queue", attributes: .concurrent)
    //static let await = DispatchQueue(label: "com.github.albertopeam.await-queue", attributes: .concurrent)
    static let main = DispatchQueue.main
}

func async(body: @escaping () throws -> Any) -> Async {
    let asyncOperation = AsyncOperation()
    Queue.main.async {
        Queue.async.async {
            do{
                let result = try body()
                Queue.main.async {
                    asyncOperation.successBlock?(result)
                }
            }catch {
                Queue.main.async {
                    asyncOperation.errorBlock?(error)
                }
            }
        }
    }
    return asyncOperation
}

protocol Async {
    typealias Result = (Any) -> Void
    typealias Reject = (Error) -> Void
    func success(result:@escaping Result) -> Async
    func error(reject:@escaping Reject)
}

class AsyncOperation: Async {
    typealias T = Any
    var successBlock:Result?
    var errorBlock:Reject?
    
    func success(result: @escaping (Any) -> Void) -> Async {
        self.successBlock = result
        return self
    }
    
    func error(reject: @escaping Async.Reject)  {
        self.errorBlock = reject
    }
}
