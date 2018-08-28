//
//  JSONDecoder.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

class JsonDecoder<OUT : Codable> {
    static func decode(data:Data) -> OUT? {
        return try! JSONDecoder().decode(OUT.self, from:data)
    }
}
