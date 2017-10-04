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
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
//        if CLLocationManager.locationServicesEnabled() {
        addCrimeData()
        whereTo()
//        }
        
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
    
    /***
        Get user's desired destination and offer routing to that destination
     ***/
    func whereTo() {
        // Hard coding to 2545 Hilliges Ave`
//        let sourceCoord = manager.location?.coordinate
        let sourceCoord = CLLocationCoordinate2DMake(self.currLocation.latitude, self.currLocation.longitude)
        let destinationCoord = CLLocationCoordinate2DMake(37.863630, -122.256088)
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoord, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate:destinationCoord, addressDictionary: nil)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .Walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0] //fastest route
            self.map.addOverlay((route.polyline), level: MKOverlayLevel.AboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
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

