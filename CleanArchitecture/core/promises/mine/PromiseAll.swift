//
//  PromiseAll.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

class PromiseAll {
    
    private var completables:Array<Completable>
    private var finalizable:Finalizable?
    private var rejectable:Rejectable?
    private var state:PromiseState
    private let workers:Array<Worker>
    private var params:Any?
    private var responses:Array<WorkerResponse>
    
    init(workers:Array<Worker>, params:Any? = nil) {
        self.completables = Array()
        self.state = .pending
        self.workers = workers
        self.params = params
        self.responses = Array()
    }
    
    private func innerResolver(worker:Worker, _ data:Any) -> Void {
        if state != .pending{
            return
        }
        responses.append(WorkerResponse(worker: worker, response: data))
        if responses.count < workers.count {            
            return
        }
        if self.completables.count > 0 {
            let completable:Completable = self.completables[0]
            self.completables.removeFirst(1)
            let response = sortResponses()
            let nextPromise:PromiseInternalProtocol = completable(response) as! PromiseInternalProtocol
            nextPromise.copy(completables: self.completables, finalizable: self.finalizable, rejectable: self.rejectable)
            nextPromise.start()
            state = .fulfilled
        }else if let final = finalizable {
            let response = sortResponses()
            final(response)
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
    
    private func sortResponses() -> Array<Any> {
        var sorted = Array<Any>()
        for worker in workers {
            for response in responses {
                if (worker as AnyObject) === (response.worker as AnyObject) {
                    sorted.append(response.response)
                    break
                }
            }
        }
        return sorted
    }
}

extension PromiseAll:PromiseInternalProtocol{
    
    func copy(completables: Array<Completable>, finalizable: Finalizable?, rejectable: Rejectable?) {
        self.completables = completables
        self.rejectable = rejectable
        self.finalizable = finalizable
    }
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            for worker in self.workers {
                do{
                    try worker.run(params: self.params, resolve: self.innerResolver, reject: self.innerReject)
                }catch {
                    self.innerReject(worker: worker, error: error)
                }
            }
        }
    }
    
}

extension PromiseAll:PromiseProtocol{
    
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

struct WorkerResponse {
    let worker:Worker
    let response:Any
}
