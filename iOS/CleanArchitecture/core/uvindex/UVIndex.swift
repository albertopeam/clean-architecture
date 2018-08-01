//
//  UVIndex.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

protocol UVIndexProtocol {
    func UVIndex(output:UVIndexOutputProtocol)
}

protocol UVIndexOutputProtocol {
    func onUVIndex(ultravioletIndex:UltravioletIndex)
    func onUVIndexError(error:Error)
}

class UltravioletIndex {
    let location:Location
    let date:String
    let timestamp:Int
    let uvIndex:Double
    init(location:Location, date:String, timestamp:Int, uvIndex:Double) {
        self.location = location
        self.date = date
        self.timestamp = timestamp
        self.uvIndex = uvIndex
    }
}

enum UVIndexError:Error {
    case noNetwork, decoding, timeout, unauthorized, other
}

class UVIndex:UVIndexProtocol {
    
    let locationWorker:Worker
    let uvIndexWorker:Worker
    
    init(locationWorker:Worker, uvIndexWorker:Worker) {
        self.locationWorker = locationWorker
        self.uvIndexWorker = uvIndexWorker
    }
    
    func UVIndex(output:UVIndexOutputProtocol) {
        Promises.once(worker: locationWorker, params: nil)
        .then { (location) -> PromiseProtocol in
            return Promises.once(worker: self.uvIndexWorker, params: location)
        }.then { (ultravioletIndex) in
            output.onUVIndex(ultravioletIndex: ultravioletIndex as! UltravioletIndex)
        }.error { (error) in
            output.onUVIndexError(error: error)
        }
    }
}
