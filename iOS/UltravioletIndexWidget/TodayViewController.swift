//
//  TodayViewController.swift
//  UltravioletIndexWidget
//
//  Created by Alberto on 16/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit
import NotificationCenter
import MapKit

internal typealias Completion = (NCUpdateResult) -> Void

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var ultravioletIndexLabel: UILabel!
    @IBOutlet weak var ultravioletIndexDescLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var viewModel:UVIndexViewModel?
    var completion:Completion?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let uvIndex = UVIndexComponent.assemble(apiKey: Constants.openWeatherApiKey)
        viewModel = UVIndexViewModel(uvIndex: uvIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        viewModel?.loadUVIndex()
        completion = completionHandler
    }
    
    private func bind(){
        viewModel?.uvIndexObservable.bind { [weak self] (newValue) in
            self?.ultravioletIndexLabel?.text = newValue
            self?.completion?(NCUpdateResult.newData)
        }
        viewModel?.descriptionObservable.bind { [weak self] (newValue) in
            self?.ultravioletIndexDescLabel.text = newValue
            self?.completion?(NCUpdateResult.newData)
        }
        viewModel?.uvIndexColorObservable.bind { [weak self] (newValue) in
            if let color = UIColor(named: newValue) {
                self?.ultravioletIndexDescLabel.textColor = color
                self?.completion?(NCUpdateResult.newData)
            }
        }
        viewModel?.locationObservable.bind { [weak self] (newValue) in
            var locations = Array<MKPointAnnotation>()
            let location = MKPointAnnotation()
            location.coordinate = CLLocationCoordinate2D(latitude: newValue.latitude, longitude: newValue.longitude)
            locations.append(location)
            self?.mapView.addAnnotation(location)
            let annotations = self?.mapView.annotations
            self?.mapView.removeAnnotations(annotations!)
            self?.mapView.showAnnotations(locations, animated: true)
            self?.completion?(NCUpdateResult.newData)
        }
        viewModel?.errorObservable.bind { [weak self] (newValue) in
            self?.completion?(NCUpdateResult.failed)
        }
    }
    
}
