//
//  AboutView.swift
//  WalkMe
//
//  Created by Karina Goot on 11/26/17.
//  Copyright © 2017 KGLG. All rights reserved.
//

import UIKit

class AboutView: UIViewController {

    @IBAction func goHomeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_home", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}
