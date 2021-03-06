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

class LoginView: UIViewController {
    
    // Variables
    let databaseRef = Database.database().reference(fromURL: "https://walkme-29.firebaseio.com/")

    // LOGIN outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var emailConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    
    // CLICK NEXT ON USERNAME Action
    @IBAction func primaryNameAction(_ sender: Any) {
        self.emailText.becomeFirstResponder()
    }
    
    // CLICK NEXT ON EMAIL Action
    @IBAction func primaryEmailAction(_ sender: Any) {
        self.passwordText.becomeFirstResponder()
    }
    
    // GO Action
    @IBAction func primaryPasswordAction(_ sender: Any) {
        beginSignIn()
    }
    
    // LOGIN Action
    @IBAction func login_action(_ sender: Any) {
        beginSignIn()
    }
    
    @IBAction func segmentControlPressed(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            self.emailConstraint.constant = 30
            self.nameConstraint.constant = 1000
        } else {
            self.emailConstraint.constant = 80
            self.nameConstraint.constant = 30
        }
    }
    
    // REDEND EMAIL Action
    @IBOutlet weak var resendBottomConstraint: NSLayoutConstraint!
    @IBAction func resendVerificationEmailAction(_ sender: Any) {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in})
        let alert = UIAlertController(title: "Your account is almost ready!", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // PROCESS USER
    func beginSignIn() {
        func handleEroor(errorMessage: String) {
            let alert = UIAlertController(title: "Error enountered", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        if emailText.text != "" && passwordText.text != "" {
            if !self.emailText.text!.hasSuffix("berkeley.edu") {
                self.performSegue(withIdentifier: "goto_sorry", sender: self)
            } else {
                if segmentControl.selectedSegmentIndex == 0 { //Login user {
                    Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                        if user != nil { //Sign in success
                            if !(user?.isEmailVerified)! {
                                let alert = UIAlertController(title: "Account not yet verified", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                                //Reveal resend option button
                                self.resendBottomConstraint.constant = 90
                                
                            } else {
                                self.completeSignIn(id: user!.uid)
                            }
                        } else { // Error
                            if let errorMessage = error?.localizedDescription {
                                handleEroor(errorMessage: errorMessage)
                            } else {
                                handleEroor(errorMessage: "Please try again.")
                            }
                        }
                    })
                }
                else { //sign up user
                    if nameText.text != "" {
                        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                            if user != nil { //success sign in
                                user?.sendEmailVerification(completion: { (error) in})
                                let alert = UIAlertController(title: "Your account is almost ready!", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                                guard let uid = user?.uid else{
                                    return
                                }
                                
                                let userReference = self.databaseRef.child("users").child(uid)
                                let values = ["username": self.emailText.text!, "email": self.emailText.text!, "pic":"", "password": self.passwordText.text!, "fullName": self.nameText.text!] //TODO(kgoot): Username and email are the same right now
                                
                                userReference.updateChildValues(values
                                    , withCompletionBlock: { (error, ref) in
                                        if error != nil{
                                            print(error!)
                                            return
                                        }
                                        self.dismiss(animated: true, completion: nil)
                                })
                                //Shift view to login once account is created
                                self.segmentControl.selectedSegmentIndex = 0
    //                            self.loginConstraint.constant = 30
                            } else {
                                if let errorMessage = error?.localizedDescription {
                                    handleEroor(errorMessage: errorMessage)
                                } else {
                                    handleEroor(errorMessage: "Please try again.")
                                }
                            }
                        })
                    } else {
                        let alert = UIAlertController(title: "Error Encountered", message: "Please fill in all the required fields", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func completeSignIn(id: String) {
        if self.emailText.text!.hasSuffix("berkeley.edu") {
            let keyChain = DataService().keyChain
            keyChain.set(id, forKey: "uid")
            self.performSegue(withIdentifier: "goto_home", sender: self)
        } else {
            self.performSegue(withIdentifier: "goto_sorry", sender: self)
        }
    }
    
    // MOVE LOGO UP
    @IBOutlet weak var imUpConst: NSLayoutConstraint!
    @IBAction func nameClicked(_ sender: Any) {
        imUpConst.constant = -220
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
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
    }
}
