//
//  Mock.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 2/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

class MockLocation {
    class Success:  Worker {
        let location:Location
        init(location:Location) {
            self.location = location
        }
        func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
            resolve(self, location
            )
        }
    }
}
