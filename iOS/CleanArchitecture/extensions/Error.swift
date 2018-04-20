//
//  Error.swift
//  sufisio
//
//  Created by Penas Amor, Alberto on 17/4/18.
//  Copyright © 2018 Sufisio. All rights reserved.
//
import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
