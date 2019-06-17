//
//  Future.swift
//  CleanArchitecture
//
//  Created by Alberto on 20/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//
//https://swiftbysundell.com/posts/under-the-hood-of-futures-and-promises-in-swift

import Foundation

class Future<Value> {
    
    fileprivate var result: Result<Value, Error>? {
        didSet { result.map(report) }
    }
    private lazy var callbacks = [(Result<Value, Error>) -> Void]()
    
    func observe(with callback: @escaping (Result<Value, Error>) -> Void) {
        callbacks.append(callback)
        result.map(callback)
    }
    
    private func report(result: Result<Value, Error>) {
        for callback in callbacks {
            callback(result)
        }
    }
    
}

class Promise<Value>: Future<Value> {
    
    override init() {}
    
    init(value: Value) {
        super.init()
        result = .success(value)
    }
    
    //TODO: state to skip n calls
    func resolve(with value: Value) {
        result = .success(value)
    }
    
    //TODO: state to skip n calls
    func reject(with error: Error) {
        result = .failure(error)
    }
    
}

extension Future {
    func chained<NextValue>(with closure: @escaping (Value) throws -> Future<NextValue>) -> Future<NextValue> {
        let promise = Promise<NextValue>()
        
        observe { result in
            switch result {
            case .success(let value):
                do {
                    let future = try closure(value)
                    
                    future.observe { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
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
