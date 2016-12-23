//
//  SelectViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// pull to refresh


import UIKit

class SelectViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    var selectedJob = PFObject(className: "Job")
    var users = [String]()
    var userId = ""
    var requesterName = ""
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var jobTitle: UILabel!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func showSelectedRow(index: Int, swipeButton: UIButton, selectLabel: UILabel) {
        let selected = selectedJob.object(forKey: "selectedUser") as! String
        if selected == users[index] {
            let buttonImage = UIImage(named: "wineIcon.png")
            swipeButton.setImage(buttonImage, for: .normal)
            selectLabel.text = "MATCHED!"
        
        } else {
            let buttonImage = UIImage(named: "handIcon.png")
            swipeButton.setImage(buttonImage, for: .normal)
            selectLabel.text = "SELECT"
            
        }
    }
    
    // drag function is called continuosly from start to end of a pan
    func dragged (gesture: UIPanGestureRecognizer) {
        // during drag, if a cell is selected/highlighted, do this, else, pan gesture has no effect nothing
        if let index = tableView.indexPathForSelectedRow {
            // get highlighted cell
            if let cell = tableView.cellForRow(at: index) {
                // measure translation of gesture in x
                let translation = gesture.translation(in: cell.contentView)
                // continue executing dragged() function if pan is to the right, if not, do nothing, function terminates
                if translation.x > 0 {
                    cell.center.x = cell.center.x + translation.x
                    // once pan gesture ends, if selected cell , pass job in highlighted cell to selectVC, perform segue
                    if gesture.state == UIGestureRecognizerState.ended {
                        if cell.center.x > (self.view.bounds.width/2) {
                            // swipe right sets selected user value
                            selectedJob.setValue(users[index.row], forKey: "selectedUser")
                            // init messaging when match is made and send message alert to user
                            let introValue = "Congratulations! " + requesterName + " picked you for the job. Connect with " + requesterName + " here"
                            let introMessage: [String : String] = ["intro" : introValue]
                            var messages = [NSDictionary]()
                            messages.append(introMessage as NSDictionary)
                            selectedJob.setValue(messages, forKey: "messages")
                            selectedJob.saveInBackground()
                            self.tableView.reloadData()
                            
                        }
                        // reset cell center to center of screen
                        cell.center.x = self.view.center.x
                        
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        tableView.delegate = self
        tableView.dataSource = self
        users = selectedJob.object(forKey: "userAccepted") as! [String]
        if users.count == 0 {
            infoLabel.text = "No users have accepted this job yet"
            
        }
        let title = selectedJob.object(forKey: "title") as! String
        jobTitle.text = title
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func viewUser(_ sender: UIButton) {
        if let id = tableView.indexPathForSelectedRow?.row {
            // pass user id to segue then perform segue
            userId = users[id]
            performSegue(withIdentifier: "toUserProfile", sender: self)
        
        } else {
            errorAlert(title: "Invalid Selection", message: "Select a user to view their profile")
            
        }
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserAcceptedTableViewCell
        // fetch user name and image and display
        do {
            let user = try PFQuery.getUserObject(withId: users[indexPath.row])
            let firstName = user.object(forKey: "first_name") as! String
            requesterName = firstName
            let lastName = user.object(forKey: "last_name") as! String
            cell.userName.text = firstName + " " + lastName
            cell.userName.sizeToFit()
            let imageFile = user.object(forKey: "image") as! PFFile
            imageFile.getDataInBackground { (data, error) in
                if let data = data {
                    let imageData = NSData(data: data)
                    cell.userImage.image = UIImage(data: imageData as Data)
                    
                } else {
                    // do nothing. placeholder image remains
                }
            }
            
        } catch _ {
            
        }
        // attach pan gesture recognizer to each cell so whenever the cell is dragged, the dragged() function runs once
        cell.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.dragged(gesture:)))
        cell.addGestureRecognizer(pan)
        showSelectedRow(index: indexPath.row, swipeButton: cell.swipeIcon, selectLabel: cell.selectLabel)
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserProfile" {
            let vc = segue.destination as! UserProfileViewController
            vc.reqId = userId
            
        }
    }

}
