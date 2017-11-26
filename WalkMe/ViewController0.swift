//
//  ViewController0.swift
//  WalkMe
//
//  Created by Karina Goot on 11/26/17.
//  Copyright © 2017 KGLG. All rights reserved.
//

import UIKit

class ViewController0: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.performSegue(withIdentifier: "goto_welcome", sender: self)
        UIView.animate(withDuration: 4.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
