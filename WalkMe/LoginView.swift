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

class LoginView: UIViewController {

    //LOGIN outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var login_button: UIButton!
    
    // NEXT Action
    @IBAction func primaryEmailAction(_ sender: Any) {
        self.passwordText.becomeFirstResponder()
    }
    
    // GO Action
    @IBAction func primaryPasswordAction(_ sender: Any) {
        beginSignIn()
    }
    
    //LOGIN Action
    @IBAction func login_action(_ sender: Any) {
        beginSignIn()
    }
    
    // PROCESS USER
    func beginSignIn() {
        if emailText.text != "" && passwordText.text != "" {
            if segmentControl.selectedSegmentIndex == 0 { //Login user {
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil { //Sign in success
                        if !(user?.isEmailVerified)! {
                            let alert = UIAlertController(title: "Account not yet verified", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.completeSignIn(id: user!.uid)
                        }
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
                if !self.emailText.text!.hasSuffix("berkeley.edu") {
                    self.performSegue(withIdentifier: "goto_sorry", sender: self)
                } else {
                    Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                        if user != nil { //success sign in
                            user?.sendEmailVerification(completion: { (error) in})
                            let alert = UIAlertController(title: "Your account is almost ready!", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            //Shift view to login once account is created
                            self.segmentControl.selectedSegmentIndex = 0
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
    
    // MOVE LOGO UP
    @IBOutlet weak var imUpConst: NSLayoutConstraint!
    @IBAction func emailedClicked(_ sender: Any) {
        imUpConst.constant = -220
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func passwordClicked(_ sender: Any) {
        imUpConst.constant = -220
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MOVE LOGO DOWN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        imUpConst.constant = 0
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }

    // LOAD VIEW
    override func viewDidLoad() {
        super.viewDidLoad()

        let keyChain = DataService().keyChain
        if keyChain.get("uid") != nil {
            self.performSegue(withIdentifier: "goto_home", sender: self) //Comment this back in to avoid having to resign in
        }
    }
}
