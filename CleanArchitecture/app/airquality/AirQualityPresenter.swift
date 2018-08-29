//
//  AirQualityPresenter.swift
//  CleanArchitecture
//
//  Created by Alberto on 27/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

protocol AirQualityPresenterProtocol {
    func getAirQuality()
}

protocol AirQualityViewProtocol {
    func newState(airQualityViewState:AirQualityViewState)
}

struct AirQualityViewState {
    let status:AirQualityViewStatus
    let airQuality:AirQualityResultViewModel?
    let error:String?
    let reqPermission:Bool
}

enum AirQualityViewStatus{
    case loading, error, success
}

struct AirQualityResultViewModel {
    let latitude:Double
    let longitude:Double
    let date:String
    let aqi:String
    let aqiColor:String
    let no2:String
    let o3:String
    let pm10:String
    let pm2_5:String
}

class AirQualityPresenter:AirQualityPresenterProtocol, AirQualityOutputProtocol {
    
    private let airQuality:AirQualityProtocol
    private let airQualityState:AirQualityViewState
    var view:AirQualityViewProtocol?
    
    init(airQuality:AirQualityProtocol, airQualityState:AirQualityViewState) {
        self.airQuality = airQuality
        self.airQualityState = airQualityState
    }
    
    func getAirQuality() {
        view?.newState(airQualityViewState: AirQualityViewState(status: .loading, airQuality: nil, error: nil, reqPermission: false))
        airQuality.getAirQuality(output: self)
    }
    
    func onGetAirQuality(airQuality: AirQualityResult) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh:mm"
        let parsedResponse = parseResponse(airQuality: airQuality)
        let aqiViewModel = AirQualityResultViewModel(latitude: airQuality.location.latitude, longitude: airQuality.location.longitude, date: formatter.string(from: airQuality.date), aqi: "AQI name: \(parsedResponse.description)", aqiColor: parsedResponse.color, no2: "NO2: \(airQuality.no2.value) \(airQuality.no2.unit)", o3: "O3: \(airQuality.o3.value) \(airQuality.o3.unit)", pm10: "PM10: \(airQuality.pm10.value) \(airQuality.pm10.unit)", pm2_5: "PM2.5: \(airQuality.pm2_5.value) \(airQuality.pm2_5.unit)")
        view?.newState(airQualityViewState: AirQualityViewState(status: .success, airQuality: aqiViewModel, error: nil, reqPermission: false))
    }
    
    func parseResponse(airQuality: AirQualityResult) -> (description:String, color:String) {
        switch airQuality.aqi {
        case .vl:
            return ("Very low", "Green")
        case .l:
            return ("Low", "Yellow")
        case .m:
            return ("Medium", "Orange")
        case .h:
            return ("High", "Red")
        case .vh:
            return ("Very high", "Violet")
        }
    }
    
    func onErrorAirQuality(error: Error) {
        let parsedError = parseError(error: error)
        view?.newState(airQualityViewState: AirQualityViewState(status: .error, airQuality: nil, error: parsedError.error, reqPermission: parsedError.reqPermission))
    }
    
    func parseError(error:Error) -> (reqPermission:Bool, error:String?) {
        switch error {
        case LocationError.noLocationPermission:
            return (true, nil)
        case LocationError.deniedLocationUsage:
            return (false, "Denied location usage")
        case LocationError.restrictedLocationUsage:
            return (false, "Restricted location usage")
        case LocationError.noLocationEnabled:
            return (false, "No location enabled")
        case LocationError.noLocation:
            return (false, "No location available")
        case AirQualityError.decoding:
            return (false, "Internal error")
        case AirQualityError.noNetwork:
            return (false, "No network")
        case AirQualityError.timeout:
            return (false, "Try again later")
        default:
            return (false, "Unknow error")
        }
    }
}
