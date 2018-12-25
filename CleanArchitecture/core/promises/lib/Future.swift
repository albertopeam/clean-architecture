//
//  Future.swift
//  CleanArchitecture
//
//  Created by Alberto on 20/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//
//https://swiftbysundell.com/posts/under-the-hood-of-futures-and-promises-in-swift

import Foundation

enum Result<Value> {
    case value(Value)
    case error(Error)
}

class Future<Value> {
    fileprivate var result: Result<Value>? {
        didSet { result.map(report) }
    }
    private lazy var callbacks = [(Result<Value>) -> Void]()
    
    func observe(with callback: @escaping (Result<Value>) -> Void) {
        callbacks.append(callback)
        result.map(callback)
    }
    
    private func report(result: Result<Value>) {
        for callback in callbacks {
            callback(result)
        }
    }
}

class Promise<Value>: Future<Value> {
    init(value: Value? = nil) {
        super.init()
        result = value.map(Result.value)
    }
    
    //TODO: state to skip n calls
    func resolve(with value: Value) {
        result = .value(value)
    }
    
    //TODO: state to skip n calls
    func reject(with error: Error) {
        result = .error(error)
    }
}

extension Future {
    func chained<NextValue>(with closure: @escaping (Value) throws -> Future<NextValue>) -> Future<NextValue> {
        let promise = Promise<NextValue>()
        
        observe { result in
            switch result {
            case .value(let value):
                do {
                    let future = try closure(value)
                    
                    future.observe { result in
                        switch result {
                        case .value(let value):
                            promise.resolve(with: value)
                        case .error(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .error(let error):
                promise.reject(with: error)
            }
        }
        
        return promise
    }
    
    func transformed<NextValue>(with closure: @escaping (Value) throws -> NextValue) -> Future<NextValue> {
        return chained { value in
            return try Promise(value: closure(value))
        }
    }
}
