//
//  AirQualityViewController.swift
//  CleanArchitecture
//
//  Created by Alberto on 24/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

//TODO: promise in main thread, pe LocationManager in main, it could not work
//TODO: generics
//TODO: remove try! from await, it should be captured by async block

class AirQualityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        async {
            //TODO: quitar el try!, el async debería capturar toda la broza y contestar a los bloques...
            let result = try! await(promise: Promises.once(worker: FakeWorker()))
            let second = try! await(promise: Promises.once(worker: Fake2Worker()))
            return result
        }.success { (result) in
            print("result: \(result)")
        }.error { (error) in
            print("error: \(error)")
        }
    }

}

class FakeWorker:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        sleep(5)
        resolve(self, "Yu Huuu!!!...")
    }
}

class Fake2Worker:Worker{
    func run(params: Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        sleep(2)
        resolve(self, "Yu asd!!!...")
    }
}

