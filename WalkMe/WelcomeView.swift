
//
//  ViewController0.swift
//  WalkMe
//
//  Created by Karina Goot on 11/26/17.
//  Copyright © 2017 KGLG. All rights reserved.
//
import UIKit
import KeychainSwift
import Firebase

class WelcomeView: UIViewController {
    
    // Variables
    // let databaseRef = Database.database().reference(fromURL: "https://walkme-29.firebaseio.com/")
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        let keyChain = DataService().keyChain
//        if keyChain.get("uid") != nil {
//            self.performSegue(withIdentifier: "goto_home", sender: self) //Comment this back in to avoid having to resign in
//        }
        
//        if keyChain.get("uid") != nil {
//            let userReference = self.databaseRef.child("users").child(keyChain.get("uid")!)
//            Auth.auth().signIn(withEmail: userReference.value(forKey: "email") as! String, password: userReference.value(forKey: "password") as! String, completion: nil)
//            self.performSegue(withIdentifier: "goto_home", sender: self) //Comment this back in to avoid having to resign in
//        }
        
        self.performSegue(withIdentifier: "goto_welcome", sender: self)
        UIView.animate(withDuration: 4.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
