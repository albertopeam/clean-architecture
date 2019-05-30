//
//  Promises.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 13/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

public class Promises {
    static func once(worker:Worker) -> PromiseProtocol {
        return PromiseOnce(worker: worker, params: nil)
    }
    
    static func once(worker:Worker, params:Any?) -> PromiseProtocol {
        return PromiseOnce(worker: worker, params: params)
    }

    static func all(workers:Array<Worker>) -> PromiseProtocol {
        return PromiseAll(workers: workers)
    }
    
    static func all(workers:Array<Worker>, params:Any?) -> PromiseProtocol {
        return PromiseAll(workers: workers, params: params)
    }
}

typealias Rejectable = (_ error:Error) -> Void
typealias Completable = (_ data:Any) -> PromiseProtocol
typealias Finalizable = (_ data:Any) -> Void

protocol PromiseProtocol {
    func then(completable:@escaping Completable) -> PromiseProtocol
    func then(finalizable:@escaping Finalizable) -> PromiseProtocol
    func error(rejectable:@escaping Rejectable)
}

protocol PromiseInternalProtocol {
    func copy(completables: Array<Completable>, finalizable: Finalizable?, rejectable: Rejectable?)
    func start()
}

typealias ResolvableWorker = (_ from:Worker, _ data:Any) -> Void
typealias RejectableWorker = (_ from:Worker, _ error:Error) -> Void

protocol Worker {
    func run(params:Any?, resolve:@escaping ResolvableWorker, reject:@escaping RejectableWorker) throws
}

extension Worker{
    func rejectIt(reject: @escaping RejectableWorker, error:Error) {
        DispatchQueue.main.sync {
            reject(self, error)
        }
    }
    
    func resolveIt(resolve: @escaping ResolvableWorker, data:Any) {
        DispatchQueue.main.sync {
            resolve(self, data)
        }
    }
}

enum PromiseState {
    case pending, fulfilled, rejected
}
