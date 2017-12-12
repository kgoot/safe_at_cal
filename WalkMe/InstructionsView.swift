//
//  InstructionsView.swift
//  WalkMe
//
//  Created by Karina Goot on 12/11/17.
//  Copyright © 2017 KGLG. All rights reserved.
//

import UIKit
import MapKit

class InstructionsView: UIViewController {
    
    var instructions: [MKRouteStep] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ello mate")
        print(self.instructions)
    }
}
