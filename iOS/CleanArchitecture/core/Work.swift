//
//  Work.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

//TODO: falta el input...
//TODO: quitar dependencia de NSObject
class Work:NSObject{
    var input:Any?
    func run(resolve:@escaping Resolve, reject:@escaping Reject) throws {}
}

