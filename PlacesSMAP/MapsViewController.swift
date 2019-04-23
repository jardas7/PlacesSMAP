//
//  MapsViewController.swift
//  PlacesSMAP
//
//  Copyright © 2019 Jaromír Hnik. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import UserNotifications
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class MapsViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    
    let defaults = UserDefaults.standard
    var tadyCounter = Int()
    
    var resultSearchController:UISearchController? = nil
    let locationManager = CLLocationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var btn: UIBarButtonItem!
    var selectedPin:MKPlacemark? = nil
    
    
    // Zoom na pozici uživatele
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
        mapView.setCamera(mapCamera, animated: true)
        print(tadyCounter)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //locManager
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
        
        //notifikace polohy
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Přístup byl povolen.")
            }
        }
        locationManager.startUpdatingLocation()
        
        
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // deletes pending scheduled notifications, there is a schedule limit qty
        
        // CSV soubor
        var data = readDataFromCSV(fileName: "test", fileType: "csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        var i = 1
        for radek in csvRows {
            if i < csvRows.count {
                
                // limit je na 64 notifikací !
                // Bez developerského programu nelze udělat push notifikace, kde tento limit není. Musel jsem se tedy zamyslet, jak to udělat jinak. Lze nastavit lokální notifikace tak, aby se program choval autonomně dle požadovaného zadání, pro další vývoj by bylo záhodno určitě zvážit napojení na firebase a s develop. accountem si osobně myslím, že nápad má veliký potenciál.
                let content = UNMutableNotificationContent()
                content.title = "Našli jsme zajímavost ve Vašem okolí :)"
                content.body = radek[3]
                content.categoryIdentifier = "alarm"
                content.sound = UNNotificationSound.default
                
                let centerLoc = CLLocationCoordinate2D(latitude: Double(radek[1]) as! CLLocationDegrees, longitude: Double(radek[0]) as! CLLocationDegrees)
                let region = CLCircularRegion(center: centerLoc, radius: 50.0, identifier: UUID().uuidString)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
                
            }
            i += 1
            
        }
        
    
    }
    
    // Pokud se stav UI Switch změní, pak se změní chování (bylo to složitější, než se zdá)
    override func viewWillAppear(_ animated: Bool) {
        if defaults.value(forKey: "switchON") != nil && defaults.value(forKey: "valueChanged") != nil{
            let switchON: Bool = defaults.value(forKey: "switchON")  as! Bool
            let valueChanged: Bool = defaults.value(forKey: "valueChanged")  as! Bool
            if switchON == true && valueChanged == true{
                showAnno()
            }
            else if switchON == false && valueChanged == true{
                mapView.removeAnnotations(mapView.annotations)
            }
        }
    }
    
    // Zobrazíme anotace pro daný soubor
    func showAnno (){
        print(tadyCounter)
       
        var data = readDataFromCSV(fileName: "test", fileType: "csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        
        var i = 1
        for radek in csvRows {
            if i < csvRows.count {
                let annotation = MKPointAnnotation()
                annotation.title = radek[2]
                annotation.subtitle = radek[3]
                annotation.coordinate = CLLocationCoordinate2D(latitude: Double(radek[1]) as! CLLocationDegrees, longitude: Double(radek[0]) as! CLLocationDegrees)
                mapView.addAnnotation(annotation)
            }
            i += 1
        }
    }
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("Nepodařilo se načíst soubor \(filepath)")
            return nil
        }
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }

    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}


// Načtení sledování polohy
extension MapsViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        print("Inicializace")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

// Obsluha vyhledávání ze Search Baru
extension MapsViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
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
        mapCamera.altitude = 500
        mapCamera.heading = 45
        mapView.setCamera(mapCamera, animated: true)
    }
}

// Předělání chování pro PIN, nabídneme uživateli navigaci k danému bodu
extension MapsViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
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
