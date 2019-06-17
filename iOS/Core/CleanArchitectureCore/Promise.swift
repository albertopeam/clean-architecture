//
//  Promise.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

internal typealias Reject = (_ error:Error) -> Void
internal typealias Resolve = (_ data:Any) -> Void
internal typealias Thenable = (_ data:Any) -> Promise
internal typealias FinalThenable = (_ data:Any) -> Void

internal enum PromiseState {
    case pending, fulfilled, rejected
}

//TODO: spec: https://github.com/promises-aplus/promises-spec
internal class Promise {
    
    private var thens:Array<Thenable>
    private var finalThen:FinalThenable?
    private var reject:Reject?
    private var state:PromiseState
    private let work:Worker
    private var params:Any?
    
    init(work:Worker, params:Any? = nil) {
        self.thens = Array()
        self.state = .pending
        self.work = work
        self.params = params
    }
    
    func then(resolve:@escaping Thenable) -> Promise {
        if thens.isEmpty {
            self.thens.append(resolve)
            start()
        }else{
            self.thens.append(resolve)
        }
        return self
    }
    
    func then(finally:@escaping FinalThenable) -> Promise {
        if self.finalThen != nil {
            assertionFailure("finally can only be called once per promise")
        }
        self.finalThen = finally
        if thens.isEmpty {
            start()
        }
        return self
    }
    
    func error(reject:@escaping Reject) {
        self.reject = reject
    }
    
    private func start() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            do{
                try self.work.run(params: self.params, resolve: self.innerResolver, reject: self.innerReject)
            }catch {
                self.innerReject(error: error)
            }
        }
    }
    
    private func innerResolver(_ data:Any) -> Void {
        if state != .pending{
            return
        }
        if self.thens.count > 0 {
            let then:Thenable = self.thens[0]
            self.thens.removeFirst(1)
            let nextPromise = then(data)
            nextPromise.reject = self.reject
            nextPromise.thens = self.thens
            nextPromise.finalThen = self.finalThen
            nextPromise.start()        
            state = .fulfilled
        }else if let finalThen = finalThen {
            finalThen(data)
            state = .fulfilled
        }
    }
    
    private func innerReject(error:Error) -> Void {
        if state != .pending{
            return
        }
        self.reject?(error)
        state = .rejected
    }
    
}

