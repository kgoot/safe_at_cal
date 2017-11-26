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
import FirebaseAuth
//import UberRides

class ViewController: UIViewController {

    //LOGIN outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var login_button: UIButton!
    
    @IBAction func login_action(_ sender: Any) {
        if emailText.text != "" && passwordText.text != "" {
            if segmentControl.selectedSegmentIndex == 0 { //Login user {
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil { //Sign in success
                        print("success login")
                        self.performSegue(withIdentifier: "goto_home", sender: self)
                    } else { // Error
                        if let myError = error?.localizedDescription {
                            print(myError)
                        } else {
                            print("Error")
                        }
                    }
                })
            }
            else { //sign up user
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil { //success sign in
                        print("success sign in")
                        self.performSegue(withIdentifier: "goto_home", sender: self)
                    } else {
                        if let myError = error?.localizedDescription {
                            print(myError)
                        } else {
                            print("Error")
                        }
                    }
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello")
    }
}
