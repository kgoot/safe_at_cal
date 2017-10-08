//
//  ViewController.swift
//  Safe@Cal
//
//  Created by Karina Goot + Lily Geerts on 9/27/17.
//  Copyright © 2017 Karina Goot Lily Geerts. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // Map UI Outlet
    @IBOutlet weak var map: MKMapView!
    
    let manager = CLLocationManager()
    var currLocation = CLLocationCoordinate2DMake(37.870586, -122.257146)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.requestAlwaysAuthorization()
        manager.requestLocation()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        map.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            addCrimeData()
            whereTo()
        }
    }
    
    /***
        Get user's desired destination and offer routing to that destination
     ***/
    func whereTo() {
        let sourceLocation = CLLocationCoordinate2D(latitude: currLocation.latitude, longitude: currLocation.longitude)
        // Hard coding to 2545 Hilliges Ave
        let destinationLocation = CLLocationCoordinate2D(latitude: 37.863630, longitude: -122.256088)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.map.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .Walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.map.addOverlay((route.polyline), level: MKOverlayLevel.AboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    /***
        Updates user's current location and displays the blue 
        dot designated current location on the map.
     ***/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.015, 0.015)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        self.currLocation = myLocation
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    /***
        Add annotations to the map displaying lat/long information
        about crimes in the area
     ***/
    func addCrimeData() {
        // Create (hard coded for now) crime objects
        let crime1:Crime = Crime.init(lat: 37.8658, long: -122.2571, datetime: NSDate(), offense: "Robbery")
        let crime2:Crime = Crime.init(lat: 37.8716, long: -122.2538, datetime: NSDate(), offense: "Armed Robbery")
        let crime3:Crime = Crime.init(lat: 37.8697, long: -122.2521, datetime: NSDate(), offense: "Aggrevated Assault")
        let crime4:Crime = Crime.init(lat: 37.8679, long: -122.2590, datetime: NSDate(), offense: "Assault with a Deadly Weapon")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy' 'HH:mm"
        
        // Add annotations to map
        for crime in [crime1, crime2, crime3, crime4] {
            let myTestAnnotation = MKPointAnnotation()
            myTestAnnotation.coordinate = CLLocationCoordinate2DMake(crime.lat, crime.long)
            myTestAnnotation.title = crime.offense
            myTestAnnotation.subtitle = dateFormatter.stringFromDate(crime.datetime)
            map.addAnnotation(myTestAnnotation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

