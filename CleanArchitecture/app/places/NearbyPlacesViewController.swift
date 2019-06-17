//
//  ViewController.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit
import MapKit

class NearbyPlacesViewController: UIViewController, NearbyPlacesViewProtocol {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var reloadNearbyButton: UIButton!
    let locationManager:CLLocationManager
    let presenter:NearbyPlacesPresenterProtocol
    var places:Array<Place> = Array()
    
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
        title = "Nearby places"
        reloadNearbyButton.layer.cornerRadius = 15
        placesTableView.register(UINib(nibName: "NearbyPlaceCell", bundle: nil), forCellReuseIdentifier: "nearby_place_cell")
        nearbyPlaces(reloadNearbyButton)
        
        
        
        
        
        let presenter = Presenter()
        presenter.performOperation()
    }
    
    @IBAction func nearbyPlaces(_ sender: UIButton) {
        presenter.nearbyPlaces()
    }
    
    func newState(viewState: NearbyPlacesViewState) {
        if let places = viewState.places {
            self.places = places
            var locations = Array<MKPointAnnotation>()
            for place in places {
                let location = MKPointAnnotation()
                location.coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
                location.title = place.name
                mapView.addAnnotation(location)
                locations.append(location)
            }
            mapView.removeAnnotations(mapView.annotations)
            mapView.showAnnotations(locations, animated: true)
            mapView.delegate = self
            placesTableView.reloadData()
        }
        if let error = viewState.error {
            presentAlert(title: "Error", message: error, button: "Ok")
        }
        if viewState.requestPermission {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension NearbyPlacesViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            nearbyPlaces(reloadNearbyButton)
        }
    }
}

extension NearbyPlacesViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearby_place_cell", for: indexPath) as! NearbyPlaceCell
        cell.draw(place:places[indexPath.row])
        return cell
    }

}

extension NearbyPlacesViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let annotation = mapView.annotations.first(where: {$0.title! == places[indexPath.row].name}) {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
}

extension NearbyPlacesViewController:MKMapViewDelegate{

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let i = places.firstIndex(where: { $0.name == view.annotation!.title! }) {
            placesTableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .middle)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let indexPath = placesTableView.indexPathForSelectedRow {
            placesTableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
