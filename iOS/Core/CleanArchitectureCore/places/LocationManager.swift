//
//  LocationManager.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 8/5/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import CoreLocation

internal class LocationManager: CLLocationManager {
    func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
}
