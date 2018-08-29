//
//  UVIndexPresenter.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//
import Foundation

enum UVIndexViewState {
    case loading, success, error
}

protocol UVIndexViewModelProtocol {
    var viewStateObservable: Observable<UVIndexViewState> { get }
    var uvIndexObservable:Observable<String> { get }
    var uvIndexColorObservable:Observable<String> { get }
    var descriptionObservable:Observable<String> { get }
    var dateObservable:Observable<String> { get }
    var locationObservable:Observable<Location> { get }
    var locationPermissionObservable:Observable<Bool> { get }
    var errorObservable:Observable<String> { get }
    var twoWayBinding:String { get set }
    func loadUVIndex()
}

class UVIndexViewModel:UVIndexViewModelProtocol, UVIndexOutputProtocol {
    
    let viewStateObservable = Observable<UVIndexViewState>(value: UVIndexViewState.loading)
    let uvIndexObservable = Observable<String>(value: "...")
    let uvIndexColorObservable = Observable<String>(value: "Black")
    let descriptionObservable = Observable<String>(value: ".....")
    let dateObservable = Observable<String>(value: "../../....")
    let locationObservable = Observable<Location>(value: Location(latitude: 0.0, longitude: 0.0))
    let locationPermissionObservable = Observable<Bool>(value: true)
    let errorObservable = Observable<String>(value: "")
    var twoWayBinding = String() {
        didSet {
            print("two way binding: \(twoWayBinding)")
        }
    }
    
    let uvIndex:UVIndexProtocol
    
    init(uvIndex:UVIndexProtocol) {
        self.uvIndex = uvIndex
    }
    
    func loadUVIndex()  {
        viewStateObservable.value = .loading
        uvIndex.UVIndex(output: self)
    }
    
    func onUVIndex(ultravioletIndex: UltravioletIndex) {
        viewStateObservable.value = .success
        dateObservable.value = formatDate(timestamp: ultravioletIndex.timestamp)
        uvIndexObservable.value = formatNumber(number: ultravioletIndex.uvIndex)
        var description = "Unknown"
        var color = "Black"
        if ultravioletIndex.uvIndex >= 0 && ultravioletIndex.uvIndex < 3 {
            description = "Low"
            color = "Green"
        } else if ultravioletIndex.uvIndex >= 3 && ultravioletIndex.uvIndex < 6 {
            description = "Moderate"
            color = "Yellow"
        } else if ultravioletIndex.uvIndex >= 6 && ultravioletIndex.uvIndex < 8 {
            description = "High"
            color = "Orange"
        } else if ultravioletIndex.uvIndex >= 8 && ultravioletIndex.uvIndex < 11 {
            description = "Very high"
            color = "Red"
        } else if ultravioletIndex.uvIndex >= 11 {
            description = "Extreme"
            color = "Violet"
        }
        descriptionObservable.value = description        
        uvIndexColorObservable.value = color
        locationObservable.value = ultravioletIndex.location
    }
    
    private func formatDate(timestamp:Int) -> String {
        let date = Date(timeIntervalSince1970:Double(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        return dateFormatter.string(from: date)
    }
    
    private func formatNumber(number:Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(for: number)!
    }
    
    func onUVIndexError(error: Error) {
        viewStateObservable.value = .error    
        switch error {
        case LocationError.noLocationPermission:
            locationPermissionObservable.value = false
            errorObservable.value = "Location services require permission"
        case LocationError.restrictedLocationUsage:
            errorObservable.value = "Location services restricted usage"
        case LocationError.noLocationEnabled:
            errorObservable.value = "Location services not available"
        case LocationError.deniedLocationUsage:
            errorObservable.value = "Location servs. doesn't have permission"
        case LocationError.noLocation:
            errorObservable.value = "Location not available"
        case UVIndexError.noNetwork:
            errorObservable.value = "Network isn't available, check connection"
        case UVIndexError.decoding:
            errorObservable.value = "Network internal error"
        case UVIndexError.timeout:
            errorObservable.value = "Network timeout"
        case UVIndexError.unauthorized:
            errorObservable.value = "Network operation is not authorized"
        case UVIndexError.other:
            errorObservable.value = "Internal error"
        default:
            errorObservable.value = "Unknow error"
        }
    }
}
