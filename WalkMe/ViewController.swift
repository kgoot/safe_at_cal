//
//  ViewController.swift
//  WalkMe
//
//  Created by Karina Goot + Lily Geerts on 10/8/17.
//  Copyright © 2017 KGLG. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var steps = [MKRouteStep]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        searchBar.delegate = self
        
        addCrimeData()
    }

    func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destination
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (responce, _) in
            guard let responce = responce else { return }
            guard let primaryRoute = responce.routes.first else { return }
            self.mapView.add(primaryRoute.polyline)
            self.steps = primaryRoute.steps
        }
    }
    
    /***
     Add annotations to the map displaying lat/long information
     about crimes in the area
     ***/
    func addCrimeData() {
        // Create (hard coded for now) crime objects
        let crime1:Crime = Crime.init(lat: 37.8658, long: -122.2571, datetime: Date(), offense: "Robbery")
        let crime2:Crime = Crime.init(lat: 37.8716, long: -122.2538, datetime: Date(), offense: "Armed Robbery")
        let crime3:Crime = Crime.init(lat: 37.8697, long: -122.2521, datetime: Date(), offense: "Aggrevated Assault")
        let crime4:Crime = Crime.init(lat: 37.8679, long: -122.2590, datetime: Date(), offense: "Assault with a Deadly Weapon")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy' 'HH:mm"
        // Add annotations to map
        for crime in [crime1, crime2, crime3, crime4] {
            let myTestAnnotation = MKPointAnnotation()
            myTestAnnotation.coordinate = CLLocationCoordinate2DMake(crime.lat, crime.long)
            myTestAnnotation.title = crime.offense
            myTestAnnotation.subtitle = dateFormatter.string(for: crime.datetime)
            mapView.addAnnotation(myTestAnnotation)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.015, 0.015)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(currentCoordinate, span)
        mapView.setRegion(region, animated: true)
        mapView.userTrackingMode = .followWithHeading
        self.mapView.showsUserLocation = true
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.015, 0.015)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(currentCoordinate, span)
        localSearchRequest.region = region
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (responce, _) in
            guard let responce = responce else { return }
            guard let mapItem = responce.mapItems.first else { return }
            
            self.getDirections(to: mapItem)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayPathRenderer()
    }
}
