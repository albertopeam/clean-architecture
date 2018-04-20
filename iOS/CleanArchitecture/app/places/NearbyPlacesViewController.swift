//
//  ViewController.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit
import MapKit

class NearbyPlacesViewController: UIViewController, NearbyPlacesView {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var reloadNearbyButton: UIButton!
    let locationManager:CLLocationManager
    let presenter:NearbyPlacesPresenterProtocol
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    init(presenter:NearbyPlacesPresenterProtocol, locationManager:CLLocationManager = CLLocationManager()) {
        self.presenter = presenter
        self.locationManager = locationManager
        super.init(nibName: "NearbyPlacesView", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Nearby places"
        nearbyPlaces(reloadNearbyButton)
    }
    
    @IBAction func nearbyPlaces(_ sender: UIButton) {
        presenter.nearbyPlaces()
    }
    
    func newState(viewModel: NearbyPlacesViewModel) {
        if let places = viewModel.places {
            var locations = Array<MKPointAnnotation>()
            for place in places {
                let location = MKPointAnnotation()
                location.coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
                location.title = place.name
                self.mapView.addAnnotation(location)
                locations.append(location)
            }
            self.mapView.showAnnotations(locations, animated: true)
        }
        if let error = viewModel.error {
            //TODO:
            switch error{
            case LocationError.noLocationPermission:
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                break
            case LocationError.deniedLocationUsage: break
            case LocationError.restrictedLocationUsage: break
            case LocationError.noLocationEnabled: break
            case LocationError.noLocation: break
            case PlacesError.noNetwork: break
            case PlacesError.decoding: break
            case PlacesError.timeout: break
            case PlacesError.noPlaces: break
            default: break
                
            }
        }
    }
}

extension NearbyPlacesViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //TODO: test
        if status == .authorizedWhenInUse {
            nearbyPlaces(reloadNearbyButton)
        }
    }
}

