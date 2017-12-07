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
import Firebase
import FirebaseAuth
import FirebaseDatabase
import KeychainSwift


class LoginView: UIViewController {

    // LOGIN outlets
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
    
    // LOGIN Action
    @IBAction func login_action(_ sender: Any) {
        beginSignIn()
    }
    
    // RESEND EMAIL Action
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
                    Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                        if user != nil { //success sign in
                            user?.sendEmailVerification(completion: { (error) in})
                            let alert = UIAlertController(title: "Your account is almost ready!", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            //Shift view to login once account is created
                            self.segmentControl.selectedSegmentIndex = 0
                        } else {
                            if let errorMessage = error?.localizedDescription {
                                handleEroor(errorMessage: errorMessage)
                            } else {
                                handleEroor(errorMessage: "Please try again.")
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
    

//        channelVc.senderDisplayName = Auth.auth().currentUser?.uid
    
    // MARK: Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        let navVc = segue.destination as! UINavigationController // 1
//        let channelVc = navVc.viewControllers.first as! ChannelListViewController // 2
//
//        channelVc.senderDisplayName = nameField?.text // 3
//    }
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        if segue.identifier == "goto_channels" {
//            let channelVc = segue.destination as! ChannelListViewController
//         //   let channelVc = segue.identifier as! "goto_channels"
//
//            channelVc.senderDisplayName = emailText.text
//        }
//    }
    
    // MARK: Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)

//         given
//        let navVc = segue.destination as! UINavigationController // 1
//        let channelVc = navVc.viewControllers.first as! ChannelListViewController // 2
//
//        channelVc.senderDisplayName = emailText?.text // 3
//
//         what I think it should be

//        if segue.identifier == "goto_channels" {
//            print("segue identifier", segue.identifier)
//            let channelVc = segue.destination as! ChannelListViewController
//            print("channelVc", channelVc)
//            channelVc.senderDisplayName = emailText?.text
//            print("senderDisplayName", channelVc.senderDisplayName)
//
//        }
//        print("not gotochannels")
//
//    }

}
