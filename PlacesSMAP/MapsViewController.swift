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
    
    @IBOutlet weak var btn: UIBarButtonItem!
    var selectedPin:MKPlacemark? = nil
    
    @IBAction func showPosition(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = mapView.userLocation.coordinate
        mapCamera.pitch = 45
        mapCamera.altitude = 500 // example altitude
        mapCamera.heading = 45
        
        // set the camera property
        mapView.camera = mapCamera

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mapView.mapType = MKMapType.standard
        mapView.showsBuildings = true // displays buildings

        
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
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
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
            annotation.subtitle = city
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = region.center
        mapCamera.pitch = 45
        mapCamera.altitude = 500 // example altitude
        mapCamera.heading = 45
        
        // set the camera property
        mapView.camera = mapCamera
    }
}

extension MapsViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.canShowCallout = true
        pinView?.animatesDrop = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "route"), for: [])
        button.addTarget(self, action:#selector(getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}
