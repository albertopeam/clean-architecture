//
//  MockWorkers.swift
//  CleanArchitectureTests
//
//  Created by Penas Amor, Alberto on 4/7/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

class MockWorkers {
    class Success:Worker{
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            resolve(self, params!)
        }
    }
    class Reject:Worker{
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            reject(self, NSError(domain: "MockWorkers.Reject", code: 0, userInfo: nil))
        }
    }
    class RejectTwice:Worker{
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            reject(self, NSError(domain: "MockWorkers.Reject", code: 0, userInfo: nil))
            reject(self, NSError(domain: "MockWorkers.Reject", code: 0, userInfo: nil))
        }
    }
    class SuccessTwice:Worker{
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            resolve(self, params!)
            resolve(self, params!)
        }
    }
    class Throw:Worker{
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            throw NSError(domain: "MockWorkers.Throw", code: 0, userInfo: nil)
        }
    }
}
