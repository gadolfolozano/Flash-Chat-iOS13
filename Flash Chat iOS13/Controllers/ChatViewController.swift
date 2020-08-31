//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db.collection("messages").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("Error fetching messages: \(e)")
            }
            
            querySnapshot?.documents.forEach({ (document) in
                let data = document.data()
                
                print("Current data: \(data)")
            })
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let message = messageTextfield.text, let sender = Auth.auth().currentUser?.email {
            db.collection("messages").addDocument(data: ["sender": sender, "message": message, "timeStamp": Date().timeIntervalSince1970]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
            }
            
            messageTextfield.text = ""
            messageTextfield.endEditing(true)
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
