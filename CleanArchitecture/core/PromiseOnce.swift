//
//  PromiseOnce.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 13/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

class PromiseOnce {
    
    private var completables:Array<Completable>
    private var finalizable:Finalizable?
    private var rejectable:Rejectable?
    private var state:PromiseState
    private let worker:Worker
    private var params:Any?
    
    init(worker:Worker, params:Any? = nil) {
        self.completables = Array()
        self.state = .pending
        self.worker = worker
        self.params = params
    }
    
    private func innerResolver(_ worker:Worker, _ data:Any) -> Void {
        if state != .pending{
            return
        }
        if self.completables.count > 0 {
            let completable:Completable = self.completables[0]
            self.completables.removeFirst(1)
            let nextPromise:PromiseInternalProtocol = completable(data) as! PromiseInternalProtocol
            nextPromise.copy(completables: self.completables, finalizable: self.finalizable, rejectable: self.rejectable)
            nextPromise.start()
            state = .fulfilled
        }else if let final = finalizable {
            final(data)
            state = .fulfilled
        }
    }
    
    private func innerReject(worker:Worker, error:Error) -> Void {
        if state != .pending{
            return
        }
        self.rejectable?(error)
        state = .rejected
    }
}

extension PromiseOnce:PromiseInternalProtocol{
    
    func copy(completables: Array<Completable>, finalizable: Finalizable?, rejectable: Rejectable?) {
        self.completables = completables
        self.rejectable = rejectable
        self.finalizable = finalizable
    }
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            do{
                try self.worker.run(params: self.params, resolve: self.innerResolver, reject: self.innerReject)
            }catch {
                self.innerReject(worker: self.worker, error: error)
            }
        }
    }
    
}

extension PromiseOnce:PromiseProtocol{
    
    func then(completable:@escaping Completable) -> PromiseProtocol{
        if completables.isEmpty {
            self.completables.append(completable)
            start()
        }else{
            self.completables.append(completable)
        }
        return self
    }
    
    func then(finalizable:@escaping Finalizable) -> PromiseProtocol{
        if self.finalizable != nil {
            assertionFailure("finally can only be called once per promise")
        }
        self.finalizable = finalizable
        if completables.isEmpty {
            start()
        }
        return self
    }
    
    func error(rejectable:@escaping Rejectable){
        self.rejectable = rejectable
    }
}
