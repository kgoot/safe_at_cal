//
//  ViewController3.swift
//  WalkMe
//
//  Created by Karina Goot on 11/25/17.
//  Copyright © 2017 KGLG. All rights reserved.
//

import UIKit

class ViewController3: UIViewController {

    @IBAction func backAction(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_login", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
