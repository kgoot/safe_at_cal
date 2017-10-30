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
//import UberRides

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
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
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
//            guard let secondaryRoute = responce.routes.filter(<#T##isIncluded: (MKRoute) throws -> Bool##(MKRoute) throws -> Bool#>)
            self.mapView.add(primaryRoute.polyline)
            self.steps = primaryRoute.steps // todo
        }
    }
    
    /***
     Read CSV data intro matrix
     ***/
    func csv() -> [[String]] {
        if let filepath = Bundle.main.path(forResource: "crimedata", ofType: "csv") {
            do {
                let data = try String(contentsOfFile: filepath)
                let rows = data.components(separatedBy: "\n")
                var result: [[String]] = []
                for row in rows {
                    let columns = row.components(separatedBy: "    ") //TODO: why doesn't \t work for me?
                    result.append(columns)
                }
                return result
            }
            catch { return []}
        }
        else { return []}
    }
    
    //return a list of crimes
    func createCrimes(rows: [[String]]) -> [Crime]{
        var crimes:[Crime] = []
        for row in rows {
            if (row.count == 5) { //TODO(kgoot) better error handling
                let offense:String = row[2]
                let latlong = row[4].components(separatedBy: ",").flatMap { Double($0.trimmingCharacters(in: .whitespaces))}
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
                let date = dateFormatter.date(from: row[3])!
                crimes.append(Crime.init(lat: latlong[0], long: latlong[1], datetime: date, offense: offense))
            }
        }
        return crimes
    }
    
    /***
     Add annotations to the map displaying lat/long information
     about crimes in the area
     ***/
    func addCrimeData() {
        let csvRows = csv()
        let crimes = createCrimes(rows: csvRows)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy' 'HH:mm"
        // Add annotations to map
        for crime in crimes {
            let myTestAnnotation = MKPointAnnotation()
            myTestAnnotation.coordinate = CLLocationCoordinate2DMake(crime.lat, crime.long)
            myTestAnnotation.title = crime.offense
            myTestAnnotation.subtitle = dateFormatter.string(for: crime.datetime)
            mapView.addAnnotation(myTestAnnotation)
        }
    }
    
    
    var routes: [MKRoute] { get {} }
    func get_route_crime_count(routes) {
        
        var route_crime_counts:[Int] = []
        var steps: [MKRouteStep] { get {} }
        for route in routes {
            var pointCount = route.polyline.pointCount
            CLLocationCoordinate2D * routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D))
            [route.polyline getCoordinates:routeCoordinates range:NSMakeRange(0, pointCount)]
            
            //this part just shows how to use the results...
            NSLog("route pointCount = %d", pointCount);
            var count:Int = 0
            let csvRows = csv()
            let crimes = createCrimes(rows: csvRows)

            for c in pointCount {
                NSLog("routeCoordinates[%d] = %f, %f",
                       c, routeCoordinates[c].latitude, routeCoordinates[c].longitude);
                for crime in crimes {
                    let myTestAnnotation = MKPointAnnotation()
                    myTestAnnotation.coordinate = CLLocationCoordinate2DMake(crime.lat, crime.long)
                    if (routeCoordinates[c].latitude == crime.lat && routeCoordinates[c].longitude == crime.long) {
                        count += 1
                    }
                }
            }
            //free the memory used by the C array when done with it...
            free(routeCoordinates);
            route_crime_counts.append(count)
        }
        var min = 0
        for i in route_crime_counts {
            if route_crime_counts[min] > route_crime_counts[i] {
                min = i
            }
        }
        return route[min]
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

//override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    // ride request button
////    let button = RideRequestButton()
//    
//    //put the button in the view
////    view.addSubview(button)
//}

// all of this until ** goes into .xcodeproj file?
//
//$ gem install cocoapods
//
//pod init
//target "WalkMe" do
//  use_frameworks!
//pod "UberRides", "~> 0.7"
//end
//$ pod install
//
//<key>UberClientID</key>
//<string>X1F-bvD7HRBx83qJNS-1GZROfz6u3tLM</string>
//<key>UberDisplayName</key>
//<string>WalkMe</string>
//<key>LSApplicationQueriesSchemes</key>
//<array>
//<string>uber</string>
//<string>uberauth</string>
//</array>




