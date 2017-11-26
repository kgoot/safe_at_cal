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
import FirebaseDatabase
import KeychainSwift
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
                        self.completeSignIn(id: user!.uid)
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
                        self.completeSignIn(id: user!.uid)
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
    
    func completeSignIn(id: String) {
        if self.emailText.text!.hasSuffix("berkeley.edu") {
            print("success login")
            let keyChain = DataService().keyChain
            keyChain.set(id, forKey: "uid")
            self.performSegue(withIdentifier: "goto_home", sender: self)
        } else {
            self.performSegue(withIdentifier: "goto_sorry", sender: self)
        }
    }
    
    @IBOutlet weak var imUpConst: NSLayoutConstraint!
    @IBAction func emailedClicked(_ sender: Any) {
        imUpConst.constant = -210
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyChain = DataService().keyChain
        if keyChain.get("uid") != nil {
//            self.performSegue(withIdentifier: "goto_home", sender: self)
        }
    }
}





