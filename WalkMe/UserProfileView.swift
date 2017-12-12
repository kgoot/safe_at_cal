//
//  UserProfileViewViewController.swift
//  WalkMe
//
//  Created by Karina Goot on 12/5/17.
//  Copyright © 2017 KGLG. All rights reserved.
//

import UIKit
import Firebase
import Photos
import KeychainSwift

class UserProfileView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // VARIABLES
    let storage = Storage.storage().reference()
    let database = Database.database().reference()
    
    // OUTLETS
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var homeAddress: UIButton!
    @IBOutlet weak var libAddress: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()

        // Make user profile round
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        loadProfileFromDatabase()
    }
    
    // UPDATE HOME ADDR
    @IBAction func updateHomeAddress(_ sender: Any) {
        let alertController = UIAlertController(title: "Home Address", message: "Please input your home address:", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if (alertController.textFields![0] as? UITextField) != nil {
                self.homeAddress.setTitle(alertController.textFields![0].text, for: .normal)

                //Add to databse!!!!!!
                if let uid = Auth.auth().currentUser?.uid {
                    self.database.child("users").child((uid)).updateChildValues(["homeAddress" : alertController.textFields![0].text!], withCompletionBlock: { (error, ref) in
                        if error != nil{
                            print(error!)
                            return
                        }
                    })
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Address"
        }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // UPDATE LIB ADDER
    @IBAction func updateLibAddress(_ sender: Any) {
        let alertController = UIAlertController(title: "Study Spot Address", message: "Please input an address:", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if (alertController.textFields![0] as? UITextField) != nil {
                self.libAddress.setTitle(alertController.textFields![0].text, for: .normal)
                if let uid = Auth.auth().currentUser?.uid {
                    self.database.child("users").child((uid)).updateChildValues(["libAddress" : alertController.textFields![0].text!], withCompletionBlock: { (error, ref) in
                        if error != nil{
                            print(error!)
                            return
                        }
                    })
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Address"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // UPDATE PROFILE PHOTO
    @IBAction func updatePhoto(_ sender: Any) {
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.notDetermined || status == PHAuthorizationStatus.denied) {
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    print("success")
                }
                else {
                    return
                }
            })
        }
        
        if status == PHAuthorizationStatus.authorized {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func goHome(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_home", sender: self)
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        let keyChain = DataService().keyChain
        keyChain.delete("uid")
        self.performSegue(withIdentifier: "goto_login", sender: self)
    }
    
    func loadProfileFromDatabase() {
        if let uid = Auth.auth().currentUser?.uid{
            database.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject]
                {
                    self.usernameLabel.text = dict["username"] as? String
                    self.nameLabel.text = dict["fullName"] as? String
                    if let profileImageURL = dict["pic"] as? String {
                        if profileImageURL != "" {
                            print("hello")
                            let url = URL(string: profileImageURL)
                            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                if error != nil{
                                    print(error!)
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.profileImage?.image = UIImage(data: data!)
                                }
                            }).resume()
                        }
                    }
                    if let home = dict["homeAddress"] as? String {
                        self.homeAddress.setTitle(home, for: .normal)
                    }
                    if let lib = dict["libAddress"] as? String {
                         self.libAddress.setTitle(lib, for: .normal)
                    }
                }
            })
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
        saveImage()
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (newStatus) in print("status is \(newStatus)"); if newStatus == PHAuthorizationStatus.authorized {
                print("success")
                
                } })
        case .restricted: print("User do not have access to photo album.")
        case .denied: print("User has denied the permission.") } }
    
    func saveImage(){
        let imageName = NSUUID().uuidString
        let storedImage = storage.child("profile_images").child(imageName)
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!)
        {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        if let uid = Auth.auth().currentUser?.uid {
                            self.database.child("users").child((uid)).updateChildValues(["pic" : urlText], withCompletionBlock: { (error, ref) in
                                if error != nil{
                                    print(error!)
                                    return
                                }
                            })
                        } else {
                            print("Bad things are happening")
                        }
                    }
                })
            })
        }
    }
}
