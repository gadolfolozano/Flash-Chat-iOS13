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
    
    var messages: [Message] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        db.collection("messages").order(by: "timeStamp").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("Error fetching messages: \(e)")
            } else {
                self.messages.removeAll()
                querySnapshot?.documents.forEach({ (document) in
                    let data = document.data()
                    
                    print("Current data: \(data)")
                    if let message = data["message"] as? String, let sender = data["sender"] as? String {
                        self.messages.append(Message(sender: sender, message: message))
                    }
                })
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    if(!self.messages.isEmpty){
                        self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            }
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

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.message
        
        if(Auth.auth().currentUser?.email == message.sender){
            cell.avatar.isHidden = false
            cell.avatarYou.isHidden = true
            
            cell.bubbleView.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
        } else {
            cell.avatar.isHidden = true
            cell.avatarYou.isHidden = false
            
            cell.bubbleView.backgroundColor = UIColor(named: K.BrandColors.blue)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.lighBlue)
        }
        
        return cell
    }
    
    
}
