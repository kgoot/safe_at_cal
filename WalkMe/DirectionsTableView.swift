//
//  Directions.swift
//  WalkMe
//
//  Created by Laptop Lending on 12/11/17.
//  Copyright © 2017 KGLG. All rights reserved.
//

import UIKit
import MapKit

class DirectionsTableView: UITableView {
    var directionsArray: [MKRouteStep]!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DirectionsTableView: UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return directionsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print(directionsArray[section].instructions)
        return directionsArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt section: Int) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell") as UITableViewCell!
        cell?.textLabel?.numberOfLines = 4
        cell?.textLabel?.font = UIFont(name: "HoeflerText-Regular", size: 12)
        cell?.isUserInteractionEnabled = false
        let instructions = directionsArray[section].instructions
        cell?.textLabel?.text = "\(instructions)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Avenir", size: 18)
        label.numberOfLines = 3
        label.text = "\nStep-by-Step Directions\n"
        return label
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Avenir", size: 18)
        label.numberOfLines = 3
        return label
    }
}

extension DirectionsTableView: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell") as UITableViewCell!
        cell?.textLabel?.numberOfLines = 4
        cell?.textLabel?.font = UIFont(name: "Avenir", size: 18)
        cell?.isUserInteractionEnabled = false
        let step = directionsArray[indexPath.row]
        let instructions = step.instructions
        let distance = step.distance.miles()
        cell?.textLabel?.text = "\(indexPath.row+1). \(instructions) - \(distance) miles"
        return cell!
    }
}

extension Float {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}

extension CLLocationDistance {
    func miles() -> String {
        let miles = Float(self)/1609.344
        return miles.format(f: ".2")
    }
}
