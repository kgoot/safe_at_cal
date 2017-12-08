//
//  Crime.swift
//  WalkMe
//
//  Created by Karina Goot on 10/2/17.
//  Copyright © 2017 Karina Goot. All rights reserved.
//

import UIKit

class Crime {
    /***
     A crime class that holds relevant information about every
     effense datapoint that exists in the system
     ***/
    
    let lat: Double
    
    let long: Double
    
    let datetime: Date
    
    let zipcode: String
    
    let offense: String
    
    init(lat: Double, long: Double, datetime: Date, zipcode: String, offense: String) {
        self.lat = lat
        self.long = long
        self.datetime = datetime
        self.zipcode = zipcode
        self.offense = offense
    }
}
