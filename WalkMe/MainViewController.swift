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
import KeychainSwift
import Firebase

typealias DataClosure = (Data?, Error?) -> Void

class MainViewController: UIViewController {
    
    // VARIABLES
    var crimes:[Crime] = []
    let database = Database.database().reference()
    lazy var geocoder = CLGeocoder()
    var instructions:[MKRouteStep] = []
    var zipcodePopuations = ["94611": 372.0,
                             "94612": 143.0,
                             "94701": 0.0,
                             "94702": 160.0,
                             "94703": 198.0,
                             "94704": 256.0,
                             "94705": 128.0,
                             "94707": 117.0,
                             "94708": 110.0,
                             "94709": 118.0,
                             "94710": 695.0,
                             "94712": 0.0,
                             "94720": 296.0] as [String : Double]
    
    //HOME outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sideBarView: UIView!
    @IBOutlet weak var homeButtonView: UIView!
    @IBOutlet weak var libraryButtonView: UIView!
    
    var heatMap = DTMHeatmap()
    
    //SIGN OUT
    @IBAction func signOut(_ sender: Any) {
        let keyChain = DataService().keyChain
        keyChain.delete("uid")
        self.performSegue(withIdentifier: "goto_login", sender: self)
    }
    
    //ABOUT
    @IBAction func about(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_about", sender: self)
    }
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var steps = [MKRouteStep]()
    
    // CHAT
    @IBAction func loadChat(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_chat", sender: self)
    }
    
    
    @IBAction func stepByStepInstructions(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowInstructions", sender: self)
    }
    
    
    //LOAD MAIN VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        mapView.delegate = self
        searchBar.delegate = self

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/29/16 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
        
        // Make buttons round
        homeButtonView.layer.cornerRadius = homeButtonView.frame.size.width / 2
        homeButtonView.clipsToBounds = true
        libraryButtonView.layer.cornerRadius = homeButtonView.frame.size.width / 2
        libraryButtonView.clipsToBounds = true
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.sideBarView.addGestureRecognizer(swipeLeft)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.left {
            if sideBarLeadConst.constant == 0 {
                sideBarLeadConst.constant = -240
            }
            if libraryBottomConst.constant == -70 {
                libraryBottomConst.constant = 70
                chatBottomConst.constant = 20
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInstructions" {
            let nextCont = segue.destination as! InstructionsView
            nextCont.instructions = self.instructions
        }
    }
    
    // HIDE KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //NAGIVAGE HOME
    @IBAction func navigateHome(_ sender: Any) {
        let keyChain = DataService().keyChain
        self.database.child("users").child(keyChain.get("uid")!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
//                print(dict)
                if let address = dict["homeAddress"] as? String {
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(address) { (placemarks, error) in
                        guard let placemarks = placemarks else {return}
                        self.getDirections(to:MKMapItem.init(placemark: MKPlacemark.init(placemark: placemarks.first!)))
                    }
                }
            }
        })
    }
    
    // NAVIGATE TO THE LIB
    @IBAction func navigateLibrary(_ sender: Any) {
        let keyChain = DataService().keyChain
        self.database.child("users").child(keyChain.get("uid")!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                print(dict)
                if let address = dict["libAddress"] as? String {
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(address) { (placemarks, error) in
                        guard let placemarks = placemarks else {return}
                        self.getDirections(to:MKMapItem.init(placemark: MKPlacemark.init(placemark: placemarks.first!)))
                    }
                }
            }
        })
    }
    
    // SHOW SIDE BAR
    @IBOutlet weak var libraryBottomConst: NSLayoutConstraint!
    @IBOutlet weak var sideBarLeadConst: NSLayoutConstraint!
    @IBOutlet weak var chatBottomConst: NSLayoutConstraint!
    
    @IBAction func openNav(_ sender: Any) {
        self.view.endEditing(true)
        if sideBarLeadConst.constant == 0 {
            sideBarLeadConst.constant = -240
        } else {
            sideBarLeadConst.constant = 0
        }
        
        if libraryBottomConst.constant == 70 {
            libraryBottomConst.constant = -70
            chatBottomConst.constant = -20
        } else {
            libraryBottomConst.constant = 70
            chatBottomConst.constant = 20
        }
    }
    
    // SIDE BAR ACTIONS
    // SHOW USER PROFILE
    @IBAction func showUserProfile(_ sender: Any) {
        if sideBarLeadConst.constant == 0 {
            sideBarLeadConst.constant = -240
        }
        if libraryBottomConst.constant == 70 {
            libraryBottomConst.constant = -70
            chatBottomConst.constant = -20
        } else {
            libraryBottomConst.constant = 70
            chatBottomConst.constant = 20
        }
        self.performSegue(withIdentifier: "goto_profile", sender: self)
    }
    // WEEKLY
    @IBAction func loadWeeklyData(_ sender: AnyObject? = nil) {
        mapView.removeAnnotations(mapView.annotations)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/20/17 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
        sideBarLeadConst.constant = -240 //TODO(kgoot) Remove Hardcode
        libraryBottomConst.constant = 70
        chatBottomConst.constant = 20
    }
    
    // MONTHLY
    @IBAction func loadMonthlyData(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/01/17 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
        sideBarLeadConst.constant = -240 //TODO(kgoot) Remove Hardcode
        libraryBottomConst.constant = 70
        chatBottomConst.constant = 20
    }
    
    // ALL
    @IBAction func loadAllData(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'HH:mm"
        let date = dateFormatter.date(from: "09/29/16 00:00")! //FIXME(kgoot) remove this hardcode
        addCrimeData(datetime: date)
        sideBarLeadConst.constant = -240 //TODO(kgoot) Remove Hardcode
        libraryBottomConst.constant = 70
        chatBottomConst.constant = 20
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
                                           edgePadding: UIEdgeInsetsMake(70.0, 50.0, 50.0, 50.0),
                                           animated: true)
            
//            self.steps = primaryRoute.steps // todo
            self.loadWeeklyData()
        }
    }
    
    func scoreRoutes(routes: [MKRoute]) -> MKRoute {
        for route in routes {
            for step in route.steps {
                let coord = step.polyline.coordinate
                let myTestAnnotation = MKPointAnnotation()
                myTestAnnotation.coordinate = CLLocationCoordinate2DMake(coord.latitude, coord.longitude)
                mapView.addAnnotation(myTestAnnotation)
            }
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
                    let columns = row.components(separatedBy: "    ")//TODO: why doesn't \t work for me?
                    result.append(columns)
                }
                return result
            }
            catch { return []}
        }
        else { return []}
    }
    
    //Load crimes from DB
    func loadCrimesFromDB(completion: @escaping (Bool) -> ()){
        let ucpdUID = "-L08_0czjNpi52a00GjZ"
        let campusUID = "-L-rkCeQY3F5CmD33x6m"
        for i in stride(from: 1, to: 18, by: 1) {
            self.database.child("crimes").child(campusUID).child(String(i)).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    let dateFormatter = DateFormatter()
                    let temp = "2017-12-12'T'00:00:00"
                    let date = Date()
                    let coord = dict["block_location"]!["coordinates"] as! [String]
                    let lat = NSString(string: coord[1]).doubleValue
                    let long = NSString(string: coord[0]).doubleValue
                    print(lat)
                    let crime = Crime.init(lat: lat, long: long, datetime: date, zipcode: "94720", offense: dict["offense"] as! String)
                    print(crime)
                    self.crimes.append(crime)
                }
            })
        }
        
        for i in stride(from: 1, to: 3001, by: 1) {
            self.database.child("crimes").child(ucpdUID).child(String(i)).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    let temp = String(describing: dict["eventdt"]!).prefix(19)
                    let date = dateFormatter.date(from: String(temp))
                    let crime = Crime.init(lat: dict["lat"] as! Double, long: dict["long"] as! Double, datetime: date!, zipcode: dict["zip"] as! String, offense: dict["offense"] as! String)
                    self.crimes.append(crime)
                    if i == 3000 {
                        completion(true)
                    }
                }
            })
        }
    }

    /***
     Add annotations to the map displaying lat/long information
     about crimes in the area
     ***/
    func addCrimeData(datetime: Date) {
        loadCrimesFromDB {
            success in
            guard success == true else {
                //Do something if some error occured while retreiving data from firebase
                print("bad")
                return
            }
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy' 'HH:mm"
       
        var heatmapdata:[NSObject: Double] = [:]
        for crime in self.crimes {
            if (crime.datetime > datetime) {
                let coordinate = CLLocationCoordinate2D(latitude: crime.lat, longitude: crime.long);
                var point = MKMapPointForCoordinate(coordinate)
                let type = "{MKMapPoint=dd}"
                let value = NSValue(bytes: &point, objCType: type)
                if self.zipcodePopuations[crime.zipcode] != nil {
                    heatmapdata[value] =  self.zipcodePopuations[crime.zipcode]! / 100
                } else {
                    print(crime.zipcode)
                    heatmapdata[value] =  1.0
                }
                
            }
        }
        self.heatMap.setData(heatmapdata as [NSObject : AnyObject])
        self.mapView.add(self.heatMap)
    }
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
//        mapView.removeAnnotations(mapView.annotations)
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3
            return renderer
        } else {
            return DTMHeatmapRenderer.init(overlay: overlay)
        }
//        return MKOverlayPathRenderer()
    }
}

extension MKPinAnnotationView {
    class func bluePinColor() -> UIColor {
        return UIColor.blue
    }
}

