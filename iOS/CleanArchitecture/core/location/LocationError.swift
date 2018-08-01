//
//  LocationError.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

enum LocationError:Error, Equatable {
    case noLocationPermission, restrictedLocationUsage, noLocationEnabled, deniedLocationUsage, noLocation
}
