//
//  LocationProtocol.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 23/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

enum AuthorizationStatus{
    case notDetermined, restricted, denied, notEnabled, authorizedAlways, authorizedWhenInUse
}

struct Location {
    let latitude:Double
    let longitude:Double
}

public enum LocationAccuracy {
    case bestForNavigation, best, nearestTenMeters, hundredMeters, kilometer, threeKilometers
}

protocol LocationManagerProtocol {
    var delegate:LocationManagerDelegate?  { get set }
    var accuracy:LocationAccuracy?  { get set }
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func authorizationStatus() -> AuthorizationStatus
}

protocol LocationManagerDelegate {
    func locationManager(didUpdateLocations locations: [Location])
    func locationManager(didFailWithError error: Error)
}
