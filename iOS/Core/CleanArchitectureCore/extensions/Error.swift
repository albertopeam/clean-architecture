//
//  Error.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

public extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
