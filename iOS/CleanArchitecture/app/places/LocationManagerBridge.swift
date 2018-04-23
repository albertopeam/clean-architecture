//
//  LocationManagerBridge.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 23/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import CoreLocation

class LocationManagerBridge:NSObject, LocationManagerProtocol {
    
    private let locationManager:CLLocationManager
    var delegate: LocationManagerDelegate?
    var accuracy: LocationAccuracy?
    
    init(locationManager:CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
    }
    
    func startUpdatingLocation() {
        if let currentAccuracy = accuracy {
            switch currentAccuracy {
            case LocationAccuracy.best:
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
            case .bestForNavigation:
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            case .nearestTenMeters:
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            case .hundredMeters:
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            case .kilometer:
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            case .threeKilometers:
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            }
        }else{
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func authorizationStatus() -> AuthorizationStatus {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            if !CLLocationManager.locationServicesEnabled() {
                return .notEnabled
            }else{
                return .denied
            }
        case .authorizedAlways:
            return .authorizedAlways
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        }
    }
}

extension LocationManagerBridge:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let target = delegate {
            let targetLocations = locations.map({ (location) -> Location in
                return Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            })
            target.locationManager(didUpdateLocations: targetLocations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let target = delegate {
            target.locationManager(didFailWithError: error)
        }
    }
}
