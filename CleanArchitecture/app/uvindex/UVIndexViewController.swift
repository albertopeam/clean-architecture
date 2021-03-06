//
//  UVIndexViewController.swift
//  CleanArchitecture
//
//  Created by Alberto on 1/8/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit
import MapKit

class UVIndexViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ultravioletIndexLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var twoWayBindTextField: UITextField!
    private let locationManager:CLLocationManager
    private var viewModel:UVIndexViewModelProtocol
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    init(viewModel:UVIndexViewModelProtocol, locationManager:CLLocationManager = CLLocationManager()) {
        self.viewModel = viewModel
        self.locationManager = locationManager
        super.init(nibName: "UVIndexViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UV index"        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "reload"), style: .plain, target: self, action: #selector(loadUVIndex))
        bind()
        loadUVIndex()
    }
    
    @IBAction func reloadUVIndex(_ sender: Any) {
        loadUVIndex()
    }
    
    @objc private func loadUVIndex(){
        viewModel.loadUVIndex()
    }
    
    private func bind(){
        viewModel.uvIndexObservable.bind { [weak self] (newValue) in
            self?.ultravioletIndexLabel?.text = newValue
        }
        viewModel.viewStateObservable.bind { [weak self] (newValue) in
            switch newValue {
            case .success:
                self?.errorView.isHidden = true
                self?.successView.isHidden = false
                self?.activityIndicator.stopAnimating()
                break
            case .error:
                self?.errorView.isHidden = false
                self?.successView.isHidden = true
                self?.activityIndicator.stopAnimating()
                break
            case .loading:
                self?.errorView.isHidden = true
                self?.successView.isHidden = true
                self?.activityIndicator.startAnimating()
                break
            }
        }
        viewModel.descriptionObservable.bind { [weak self] (newValue) in
            self?.descriptionLabel.text = newValue
        }
        viewModel.dateObservable.bind { [weak self] (newValue) in
            self?.dateLabel.text = newValue
        }
        viewModel.uvIndexColorObservable.bind { [weak self] (newValue) in
            if let color = UIColor(named: newValue) {
                self?.ultravioletIndexLabel.textColor = color
            }            
        }
        viewModel.locationObservable.bind { [weak self] (newValue) in
            var locations = Array<MKPointAnnotation>()
            let location = MKPointAnnotation()
            location.coordinate = CLLocationCoordinate2D(latitude: newValue.latitude, longitude: newValue.longitude)
            locations.append(location)
            self?.mapView.addAnnotation(location)
            let annotations = self?.mapView.annotations
            self?.mapView.removeAnnotations(annotations!)
            self?.mapView.showAnnotations(locations, animated: true)
        }
        viewModel.locationPermissionObservable.bind { [weak self] (newValue) in
            if !newValue {
                self?.locationManager.delegate = self
                self?.locationManager.requestWhenInUseAuthorization()
            }
        }
        viewModel.errorObservable.bind { [weak self] (newValue) in
            if !newValue.isEmpty {
                self?.errorMessageLabel.text = newValue
            }
        }
    }
}

extension UVIndexViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            loadUVIndex()
        }
    }
}

extension UVIndexViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            self.viewModel.twoWayBinding = text
        }
        return true
    }
}
