//
//  ViewController2.swift
//  WalkMe
//
//  Created by Karina Goot on 11/25/17.
//  Copyright © 2017 KGLG. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import DTMHeatmap

class MainViewController: UIViewController {
    
    //HOME outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var heatMap = DTMHeatmap()
    
    //SIGN OUT
    @IBAction func signOut(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_login", sender: self)
    }
    
    //ABOUT
    @IBAction func about(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_about", sender: self)
    }
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var steps = [MKRouteStep]()
    
    //LOAD MAIN VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        _ = Auth.auth().currentUser
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        mapView.delegate = self
        searchBar.delegate = self
//        searchCompleter.delegate = self

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/29/16 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
    }
    
    // HIDE KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // SHOW SIDE BAR
    @IBOutlet weak var sideBarLeadConst: NSLayoutConstraint!
    @IBAction func openNav(_ sender: Any) {
        if sideBarLeadConst.constant == 0 {
            sideBarLeadConst.constant = -240
        } else {
            sideBarLeadConst.constant = 0
        }
    }

    // SIDE BAR ACTIONS
    // WEEKLY
    @IBAction func loadWeeklyData(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/20/17 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
        sideBarLeadConst.constant = -240 //TODO(kgoot) Remove Hardcode
    }
    
    // MONTHLY
    @IBAction func loadMonthlyData(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/01/17 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
        sideBarLeadConst.constant = -240 //TODO(kgoot) Remove Hardcode
    }
    
    // ALL
    @IBAction func loadAllData(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/29/16 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
        sideBarLeadConst.constant = -240 //TODO(kgoot) Remove Hardcode
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
            let routes = responce.routes
            
            let primaryRoute: MKRoute;
            if (routes.count >= 1) { //FIXME
                // score routes and find best one based on data
                primaryRoute = self.scoreRoutes(routes: routes)
            } else {
                primaryRoute = responce.routes.first!
            }
            
            self.mapView.add(primaryRoute.polyline)
            self.mapView.setVisibleMapRect(primaryRoute.polyline.boundingMapRect,
                                           edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                           animated: true)
            self.steps = primaryRoute.steps // todo
        }
    }
    
    func scoreRoutes(routes: [MKRoute]) -> MKRoute {
        for route in routes {
            print("hello world")
            for step in route.steps {
                let coord = step.polyline.coordinate
                //                MKPinAnnotationView.bluePinColor()
                let myTestAnnotation = MKPointAnnotation()
                myTestAnnotation.coordinate = CLLocationCoordinate2DMake(coord.latitude, coord.longitude)
                mapView.addAnnotation(myTestAnnotation)
            }
            print("end world")
        }
        return routes.first!
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
    func addCrimeData(datetime: Date) {
        let csvRows = csv()
        let crimes = createCrimes(rows: csvRows)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy' 'HH:mm"
       
        var heatmapdata:[NSObject: Double] = [:]

//        var coords:[CLLocationCoordinate2D] = []
        for crime in crimes {
            if (crime.datetime > datetime) {
                let coordinate = CLLocationCoordinate2D(latitude: crime.lat, longitude: crime.long);
                var point = MKMapPointForCoordinate(coordinate)
                let type = "{MKMapPoint=dd}"
                let value = NSValue(bytes: &point, objCType: type)
                heatmapdata[value] = 1.0
                
//                let mapPoint = MKMapPointForCoordinate(coordinate)
//                let value = NSValue(MKMapPoint: mapPoint)

            }
        }
        self.heatMap.setData(heatmapdata as [NSObject : AnyObject])
        self.mapView.add(self.heatMap)

        //        var dict = Dictionary()
//        self.heatmap.setData(dict)
//        // Add annotations to map
//        for crime in crimes {
//            if (crime.datetime > datetime) {
//                let myTestAnnotation = MKPointAnnotation()
//                myTestAnnotation.coordinate = CLLocationCoordinate2DMake(crime.lat, crime.long)
//                myTestAnnotation.title = crime.offense
//                myTestAnnotation.subtitle = dateFormatter.string(for: crime.datetime)
//                mapView.addAnnotation(myTestAnnotation)
//            }
//        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate

        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.015, 0.015)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(currentCoordinate, span)
        mapView.setRegion(region, animated: true)
//        mapView.userTrackingMode = .followWithHeading
        self.mapView.showsUserLocation = true
    }
}

extension MainViewController: UISearchBarDelegate {
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

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return DTMHeatmapRenderer.init(overlay: overlay)
//        if overlay is MKPolyline {
//            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeColor = .blue
//            renderer.lineWidth = 5
//            return renderer
//        }
//        return MKOverlayPathRenderer()
    }
}

extension MKPinAnnotationView {
    class func bluePinColor() -> UIColor {
        return UIColor.blue
    }
}

