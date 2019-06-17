//
//  LocationWorker.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import CoreLocation

class LocationWorker: NSObject, Worker {
    
    private var resolve:ResolvableWorker?
    private var reject:RejectableWorker?
    private let locationManager:LocationManager
    private let accuracy:CLLocationAccuracy
    
    init(locationManager:LocationManager = LocationManager(), accuracy:CLLocationAccuracy = kCLLocationAccuracyBest) {
        self.locationManager = locationManager
        self.accuracy = accuracy
    }
    
    func run(params:Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        self.resolve = resolve
        self.reject = reject
        switch locationManager.authorizationStatus() {
        case .notDetermined:
            reject(self, LocationError.noLocationPermission)
            return
        case .restricted:
            reject(self, LocationError.restrictedLocationUsage)
            return
        case .denied:
            if !CLLocationManager.locationServicesEnabled() {
                if !CLLocationManager.locationServicesEnabled() {
                    reject(self, LocationError.noLocationEnabled)
                }else{
                    reject(self, LocationError.deniedLocationUsage)
                }
            }else{
                reject(self, LocationError.deniedLocationUsage)
            }
            return
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break        
        @unknown default:
            fatalError()
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = accuracy;
        locationManager.startUpdatingLocation()
    }
}

extension LocationWorker:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let location:CLLocation = locations.first!
            resolve?(self, Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        if error.code == 0 && error.domain == "kCLErrorDomain" {
            reject?(self, LocationError.noLocation)
        }else{
            reject?(self, error)
        }
    }
}
