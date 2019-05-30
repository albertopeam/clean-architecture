//
//  LocationJob.swift
//  CleanArchitecture
//
//  Created by Alberto on 22/12/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation
import CoreLocation

class LocationJob: NSObject, CLLocationManagerDelegate {
    
    private let locationManager:LocationManager
    private let accuracy:CLLocationAccuracy
    private let promise: Promise<Location>
    private let noPermissionError: Error
    private let noLocationError: Error
    private let locationNotEnabledError: Error
    private let deniedLocationError: Error
    private let restrictedLocationError: Error
    
    init(locationManager:LocationManager = LocationManager(),
         accuracy:CLLocationAccuracy = kCLLocationAccuracyBest,
         noPermissionError: Error = LocationError.noLocationPermission,
         noLocationError: Error = LocationError.noLocation,
         locationNotEnabledError: Error = LocationError.noLocationEnabled,
         deniedLocationError: Error = LocationError.deniedLocationUsage,
         restrictedLocationError: Error = LocationError.restrictedLocationUsage) {
        self.locationManager = locationManager
        self.accuracy = accuracy
        self.noPermissionError = noPermissionError
        self.noLocationError = noLocationError
        self.locationNotEnabledError = locationNotEnabledError
        self.deniedLocationError = deniedLocationError
        self.restrictedLocationError = restrictedLocationError
        self.promise = Promise<Location>()
    }
    
    func location() -> Promise<Location> {
        switch locationManager.authorizationStatus() {
        case .notDetermined:
            promise.reject(with: noPermissionError)
        case .restricted:
            promise.reject(with: restrictedLocationError)
        case .denied:
            if !CLLocationManager.locationServicesEnabled() {
                if !CLLocationManager.locationServicesEnabled() {
                    promise.reject(with: locationNotEnabledError)
                }else{
                    promise.reject(with: deniedLocationError)
                }
            }else{
                promise.reject(with: deniedLocationError)
            }
        case .authorizedAlways:
            startObservingLocation()
        case .authorizedWhenInUse:
            startObservingLocation()            
        @unknown default:
            fatalError()
        }
        return promise
    }
    
    private func startObservingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = accuracy;
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let location = Location(latitude: last.coordinate.latitude, longitude: last.coordinate.longitude)
            promise.resolve(with: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        if error.code == 0 && error.domain == "kCLErrorDomain" {
            promise.reject(with: noLocationError)
        }else{
            promise.reject(with: error)
        }
    }
}
