//
//  LocationGateway.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import CoreLocation

class LocationGateway:Work, CLLocationManagerDelegate {
    
    private var resolve:Resolve?
    private var reject:Reject?
    private var locationManager:CLLocationManager
    
    init(locationManager:CLLocationManager) {
        self.locationManager = locationManager
    }
    
    override func run(resolve: @escaping (Any) -> Void, reject: @escaping Reject) throws {
        self.resolve = resolve
        self.reject = reject
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            //never ask
            reject(LocationError.noLocationPermission)
            return
        case .restricted:
            //parental controls
            reject(LocationError.restrictedLocationUsage)
            return
        case .denied:
            if !CLLocationManager.locationServicesEnabled() {
                reject(LocationError.noLocationEnabled)
            }else{
                reject(LocationError.deniedLocationUsage)
            }
            return
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            locationManager.stopUpdatingLocation()
            let location:CLLocation = locations.first!
            resolve?(Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        if error.code == 0 && error.domain == "kCLErrorDomain"{
            reject?(LocationError.noLocation)
        }
    }
}
