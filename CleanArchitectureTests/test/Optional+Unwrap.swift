//
//  Unwrap.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 15/03/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import Foundation

extension Optional {
    
    func unwrap() throws -> Wrapped {
        guard let self = self else {
            throw OptionalError.null
        }
        return self
    }
    
}

enum OptionalError: Swift.Error {
    case null
}
