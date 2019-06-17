//
//  Async.swift
//  CleanArchitecture
//
//  Created by Alberto on 24/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

//TODO: promises in main thread won't work. Please create a way to handle in a RunLoop or whatever,,, especial case is LocationManager.
import Foundation

struct Queue {
    static let async = DispatchQueue(label: "com.github.albertopeam.async-queue", attributes: .concurrent)
    static let main = DispatchQueue.main
}

func async<T>(body: @escaping () throws -> T) -> Async<T> {
    let asyncOperation = Async<T>()
    Queue.main.async {
        Queue.async.async {
            do{
                let result:T = try body()
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

class Async<T> {
    
    typealias AsyncResult = (T) -> Void
    typealias Reject = (Error) -> Void
    fileprivate var successBlock:AsyncResult?
    fileprivate var errorBlock:Reject?
    
    func success(result: @escaping Async.AsyncResult) -> Async<T> {
        self.successBlock = result
        return self
    }
    
    func error(reject: @escaping Async.Reject)  {
        self.errorBlock = reject
    }
}

