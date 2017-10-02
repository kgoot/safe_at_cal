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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        addCrimeData()
    }
    
    /***
        Updates user's current location and displays the blue 
        dot designated current location on the map.
     ***/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.015, 0.015)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
    }
    
    /***
        Add annotations to the map displaying lat/long information
        about crimes in the area
     ***/
    func addCrimeData() {
        // Create (hard coded) crime object
        let crime:Crime = Crime.init(lat: 37.8658, long: -122.2571, datetime: NSDate(), offense: "Robbery")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy' 'HH:mm"
        
        // Add annotation to map
        let myTestAnnotation = MKPointAnnotation()
        myTestAnnotation.coordinate = CLLocationCoordinate2DMake(crime.lat, crime.long)
        myTestAnnotation.title = crime.offense
        myTestAnnotation.subtitle = dateFormatter.stringFromDate(crime.datetime)
        map.addAnnotation(myTestAnnotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

