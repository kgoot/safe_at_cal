
import UIKit
import MapKit
import CoreLocation

class DirectionsViewController: UIViewController {
    
    @IBOutlet weak var directionsTableView: DirectionsTableView!
    
    @IBAction func goHomeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_home", sender: self)
    }
    
    var activityIndicator: UIActivityIndicatorView?
    var locationArray: [(textField: UITextField?, mapItem: MKMapItem?)]!
    var primaryRoute: MKRoute!
    
    var instructions: [MKRouteStep] = []
    
    
    func displayDirections(primaryRoute: MKRoute, time: TimeInterval) {
        var directionsArray: [MKRouteStep] = []
        
        for step in primaryRoute.steps {
            // print(step.instructions)
            // print(step)
            directionsArray.append(step)
        }
        // print("done appending steps")
        displayDirections(directionsArray: directionsArray)
        
    }
    
    func displayDirections(directionsArray: [MKRouteStep]) {
        
        directionsTableView.directionsArray = directionsArray
        directionsTableView.delegate = directionsTableView
        directionsTableView.dataSource = directionsTableView
        directionsTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicator()
        calculateSegmentDirections(index: 0, time: 0, routes: [])
        
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        activityIndicator?.activityIndicatorViewStyle = .whiteLarge
        activityIndicator?.backgroundColor = view.backgroundColor
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
    }
    
    func hideActivityIndicator() {
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    func calculateSegmentDirections(index: Int,
                                    time: TimeInterval, routes: [MKRoute]) {
        
        let quickestRouteForSegment: MKRoute = primaryRoute
        var timeVar = time
        timeVar += quickestRouteForSegment.expectedTravelTime
        self.displayDirections(primaryRoute: quickestRouteForSegment, time: timeVar)
        self.hideActivityIndicator()
        
    }
}

