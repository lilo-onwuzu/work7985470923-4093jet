//
//  MessageTableViewCell.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MessageTableViewCell: UITableViewCell {

    var selectedJob = PFObject(className: "Job")
    var myTableView = UITableView()
    var ready = false
    var newReqCount = Int()
    var newUserCount = Int()
    
    @IBOutlet weak var reqImage: UIImageView!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var swipeIcon: UIButton!
    @IBOutlet weak var connectLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imageFrame: UIButton!
    @IBOutlet weak var notification: UILabel!
    
    func recenter () {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .transitionCrossDissolve,
                       animations: { self.swipeIcon.center.x -= 30 },
                       completion: nil
        )
    }
    
    // drag function is called continuosly from start to end of a pan
    func dragged (gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.contentView)
        // continue executing dragged() function if pan is to the right, if not, do nothing, function terminates
        if translation.x > 0 {
            self.center.x = self.center.x + translation.x
            // once pan gesture ends, if selected cell , pass job in highlighted cell to selectVC, perform segue
            if gesture.state == UIGestureRecognizerState.ended {
                if self.center.x > (self.bounds.width/2) {
                    ready = true
                    // reload tableView to get "SelectVC" segue instruction
                    myTableView.reloadData()
                    
                }
                // reset cell center to center of screen
                self.center.x = self.bounds.width/2
                
            }
        }
    }
    
    func getCount() {
        let messages = selectedJob.object(forKey: "messages") as! [NSDictionary]
        var i = 0
        var j = 0
        let userid = PFUser.current()?.objectId!
        let requesterId = selectedJob.object(forKey: "requesterId") as! String
        for message in messages {
            // save for req
            if userid == requesterId {
                if (message.object(forKey: "user") as? String) != nil {
                    i += 1
                    selectedJob.setValue(i, forKey: "userSaveForReq")
                    selectedJob.saveInBackground()
                    
                }
            // save for user
            } else {
                if (message.object(forKey: "req") as? String) != nil {
                    j += 1
                    selectedJob.setValue(j, forKey: "reqSaveForUser")
                    selectedJob.saveInBackground()
                    
                }
            }
        }
    }
    
    func newCount() {
        // get number of messages from user and req now
        let messages = selectedJob.object(forKey: "messages") as! [NSDictionary]
        let userid = PFUser.current()?.objectId!
        let requesterId = selectedJob.object(forKey: "requesterId") as! String
        let selectedId = selectedJob.object(forKey: "selectedUser") as! String
        // if this is the req interacting, pull requester notification data
        if userid == requesterId {
            // get number of messages from user and req previously stored the last time viewDidLoad for req
            let i0 = selectedJob.object(forKey: "userSaveForReq") as! Int
            // get number of messages from user and req now
            var i = 0
            for message in messages {
                if (message.object(forKey: "user") as? String) != nil {
                    i += 1
                    newUserCount = i - i0
                    // fetch selected user's name
                    var selectedName = ""
                    var userSelected = PFObject(className: "User")
                    let query: PFQuery = PFUser.query()!
                    query.whereKey("objectId", equalTo: selectedId)
                    query.findObjectsInBackground { (users, error) in
                        if let users = users {
                            userSelected = users[0]
                            selectedName = userSelected.object(forKey: "first_name") as! String
                            if self.newUserCount == 1 {
                                self.notification.text = String(self.newUserCount) + " new message from " + selectedName
                                
                            } else {
                                self.notification.text = String(self.newUserCount) + " new messages from " + selectedName
                                
                            }
                        }
                    }
                }
            }
        // if this is the selected user interacting, pull user notification data
        } else {
            // get number of messages from user and req previously stored the last time viewDidLoad for user
            let i0 = selectedJob.object(forKey: "reqSaveForUser") as! Int
            var i = 0
            for message in messages {
                if (message.object(forKey: "req") as? String) != nil {
                    i += 1
                    newReqCount = i - i0
                    // fetch requester's name
                    var reqName = ""
                    var requester = PFObject(className: "User")
                    let query: PFQuery = PFUser.query()!
                    query.whereKey("objectId", equalTo: requesterId)
                    query.findObjectsInBackground { (users, error) in
                        if let users = users {
                            requester = users[0]
                            reqName = requester.object(forKey: "first_name") as! String
                            if self.newReqCount == 1 {
                                self.notification.text = String(self.newReqCount) + " new message from " + reqName
                                
                            } else {
                                self.notification.text = String(self.newReqCount) + " new messages from " + reqName
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 5
        reqImage.layer.masksToBounds = true
        reqImage.layer.cornerRadius = 45
        imageFrame.layer.cornerRadius = 45
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            self.messageTitle.textColor = UIColor.black
            swipeIcon.isHidden = false
            connectLabel.isHidden = false
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.0,
                           options: .transitionCrossDissolve,
                           animations: { self.swipeIcon.center.x += 30 },
                           completion: { (success) in
                                        self.recenter()
                            
            })
            // attach pan gesture recognizer to each cell so whenever the selected cell is dragged, the dragged() function runs once
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.dragged(gesture:)))
            addGestureRecognizer(pan)
            
        } else {
            self.messageTitle.textColor = UIColor.white
            swipeIcon.isHidden = true
            connectLabel.isHidden = true
            
        }
    }

}
