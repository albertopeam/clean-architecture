//
//  LocationGateway.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

class LocationGateway: Work, LocationManagerDelegate {
    
    private var resolve:Resolve?
    private var reject:Reject?
    private var locationManager:LocationManagerProtocol
    
    init(locationManager:LocationManagerProtocol) {
        self.locationManager = locationManager
    }
    
    func run(params:Any?, resolve: @escaping (Any) -> Void, reject: @escaping Reject) throws {
        self.resolve = resolve
        self.reject = reject
        switch locationManager.authorizationStatus() {
        case .notDetermined:
            reject(LocationError.noLocationPermission)
            return
        case .restricted:
            reject(LocationError.restrictedLocationUsage)
            return
        case .denied:
            reject(LocationError.deniedLocationUsage)
            return
        case .notEnabled:
            reject(LocationError.noLocationEnabled)
            return
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        
        }
        locationManager.delegate = self
        locationManager.accuracy = .best;
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(didUpdateLocations locations: [Location]) {
        if locations.count > 0 {
            locationManager.stopUpdatingLocation()
            resolve?(locations.first!)
        }
    }
    
    func locationManager(didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        if error.code == 0 && error.domain == "kCLErrorDomain"{
            reject?(LocationError.noLocation)
        }
    }
}
