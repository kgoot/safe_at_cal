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
    var messages = [JSQMessage]()
    var channelRef: DatabaseReference?
    let database = Database.database().reference()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    private lazy var usersTypingQuery: DatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    private lazy var userIsTypingRef: DatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId)
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }

    
    // Properties
    
    // View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello worlddd")
        let uid = Auth.auth().currentUser?.uid
        self.senderId = uid
        self.senderDisplayName = "displayname"
        self.database.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                if let email = dict["email"] as? String {
                    print("test")
                    self.senderDisplayName = email
                }
            }
        })
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
     //   self.senderDisplayName = "Karina Goot"
    //    self.senderId = "yaCSoKfLViWycYQcJShATm2uemS2"
        if channel != nil {
            observeMessages()
        }
        // observeMessages()
        
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // set bubble image for a message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // remove avatars ???
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    // creates a new JSQMessage and adds to data source
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        print("why")
//        super.viewDidAppear(animated)
//        print("fuck")
//        // messages from someone else
//        addMessage(withId: "foo", name: "Mr.Bolt", text: "I am so fast!")
//        // messages sent from local sender
//        addMessage(withId: senderId, name: "Me", text: "I bet I can run faster than you!")
//        addMessage(withId: senderId, name: "Me", text: "I like to run!")
//        // animates the receiving of a new message on the view
//        finishReceivingMessage()
//    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    // create dict to store messages, store in firebase
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    private func observeMessages() {
   //     if channelRef!.child("messages") != nil {
        messageRef = channelRef!.child("messages")
      //  }
      //  messageRef = channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    
    
    /// ... typing dots appear
//    override func textViewDidChange(_ textView: UITextView) {
//        super.textViewDidChange(textView)
//        // If the text is not empty, the user is typing
//        //print(textView.text != "")
//        isTyping = textView.text != ""
//    }
    
//    private func observeTyping() {
//        let typingIndicatorRef = channelRef!.child("typingIndicator")
//        userIsTypingRef = typingIndicatorRef.child(senderId)
//        userIsTypingRef.onDisconnectRemoveValue()
//        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
//            // You're the only one typing, don't show the indicator
//            if data.childrenCount == 1 && self.isTyping {
//                return
//            }
//
//            // Are there others typing?
//            self.showTypingIndicator = data.childrenCount > 0
//            self.scrollToBottom(animated: true)
//        }
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        observeTyping()
//    }
    
    
    // UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
}
