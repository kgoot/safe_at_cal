//
//  ChatViewController.swift
//  WalkMe
//
//  Created by Laptop Lending on 12/4/17.
//  Copyright © 2017 KGLG. All rights reserved.
//  * Copyright (c) 2015 Razeware LLC

import Foundation
import UIKit
import Firebase
import JSQMessagesViewController


// final class ChatViewController: UIViewController {
final class ChatViewController: JSQMessagesViewController {
    var channelRef: DatabaseReference?
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }
    
    // MARK: Properties
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = Auth.auth().currentUser?.uid
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Collection view data source (and related) methods
    
    
    // MARK: Firebase related methods
    
    
    // MARK: UI and User Interaction
    
    
    // MARK: UITextViewDelegate methods
    
}
