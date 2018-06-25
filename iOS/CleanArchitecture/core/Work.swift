//
//  Work.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

/**
 * @deprecated
 * @note Please use instead static factory @code Promises.once(...) or Promises.all(...) @endcode .
 */
protocol Work {
    func run(params:Any?, resolve:@escaping Resolve, reject:@escaping Reject) throws
}

