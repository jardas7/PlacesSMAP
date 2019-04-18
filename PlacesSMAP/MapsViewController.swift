//
//  MapsViewController.swift
//  PlacesSMAP
//
//  Created by Jaromír Hnik on 18/04/2019.
//  Copyright © 2019 Jaromír Hnik. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class MapsViewController: UIViewController {
    var resultSearchController:UISearchController? = nil
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearch = storyboard!.instantiateViewController(withIdentifier: "LocationSearch") as! LocationSearch
        resultSearchController = UISearchController(searchResultsController: locationSearch)
        resultSearchController?.searchResultsUpdater = locationSearch as UISearchResultsUpdating
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Vyhledejte místo"
        searchBar.setValue("Zrušit", forKey:"_cancelButtonText")
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearch.mapView = mapView
        locationSearch.handleMapSearchDelegate = self
    }
}

extension MapsViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

extension MapsViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
