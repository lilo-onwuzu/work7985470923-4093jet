//
//  SelectViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SelectViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    var selectedJob = PFObject(className: "Job")
    var users = [String]()
    var userId = ""
    var requesterName = ""
    var refresher: UIRefreshControl!
    var user = PFUser.current()!
    
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
    
    func tossDownIcon (swipeIcon: UIButton) {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .transitionCrossDissolve,
                       animations: { swipeIcon.center.y += 15 },
                       completion: nil)
    
    }
    
    func showSelectedRow(index: Int, swipeButton: UIButton, selectLabel: UILabel) {
        let selected = selectedJob.object(forKey: "selectedUser") as! String
        
        // when cell in select vc is swiped, this function will cause changes to the UI that show that a user has been selected
        if selected == users[index] {
            let buttonImage = UIImage(named: "wineIcon.png")
            swipeButton.setImage(buttonImage, for: .normal)
            selectLabel.text = "MATCHED!"
            // if selectedUser id matches row of user, animate and toss swipeIcon up +30 then toss back down -30
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.0,
                           options: .transitionCrossDissolve,
                           animations: { swipeButton.center.y -= 15 },
                           completion: { (success) in
                            self.tossDownIcon(swipeIcon: swipeButton)
                            
            })
        } else {
            let buttonImage = UIImage(named: "handIcon.png")
            swipeButton.setImage(buttonImage, for: .normal)
            selectLabel.text = "SWIPE TO SELECT"
            
        }
    }
    
    func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
        
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
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        self.view.sendSubview(toBack: tableView)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! SelectTableViewCell
        // once cell is swiped right, cell.ready becomes true and the tableview is reloaded which causes this to load too
        
        if cell.ready {
            cell.ready = false
            // set swiped user as selectedUser
            let initiallySelectedId = selectedJob.object(forKey: "selectedUser") as! String
            // but only if the selectedUser is different from the initially selected one
            if initiallySelectedId != users[indexPath.row] {
                selectedJob.setValue(users[indexPath.row], forKey: "selectedUser")
                // init messaging when match is made and add new message to array
                let firstName = user.object(forKey: "first_name") as! String
                // fetch selected user's name
                var selectedName = ""
                var userSelected = PFObject(className: "User")
                let query: PFQuery = PFUser.query()!
                query.whereKey("objectId", equalTo: users[indexPath.row])
                query.findObjectsInBackground { (users, error) in
                    if let users = users {
                        userSelected = users[0]
                        selectedName = userSelected.object(forKey: "first_name") as! String
                        let introValue = "Congratulations " + selectedName + "! " + firstName + " picked you for the job. Connect with " + firstName + " here"
                        let introMessage: [String : String] = ["intro" : introValue]
                        var messages = [NSDictionary]()
                        messages.append(introMessage as NSDictionary)
                        self.selectedJob.setValue(messages, forKey: "messages")
                        self.selectedJob.saveInBackground()
                        // reload table view to show new user selection
                        tableView.reloadData()
                        
                    }
                }
            }
        }
        
        // fetch user name and image and display 
        var userAccepted = PFObject(className: "User")
        let query: PFQuery = PFUser.query()!
        query.whereKey("objectId", equalTo: users[indexPath.row])
        query.findObjectsInBackground { (users, error) in
            if let users = users {
                userAccepted = users[0]
                let firstName = userAccepted.object(forKey: "first_name") as! String
                let lastName = userAccepted.object(forKey: "last_name") as! String
                cell.userName.text = firstName + " " + lastName
                let imageFile = userAccepted.object(forKey: "image") as! PFFile
                imageFile.getDataInBackground { (data, error) in
                    if let data = data {
                        let imageData = NSData(data: data)
                        cell.userImage.image = UIImage(data: imageData as Data)
                        
                    }
                }
            }
        }
        // when cell in select vc is swiped, this function will cause changes to the UI that show that a user has been selected
        showSelectedRow(index: indexPath.row, swipeButton: cell.swipeIcon, selectLabel: cell.selectLabel)
        // return some other variables needed for operations within the respective cells
        cell.myTableView = tableView
        cell.selectedJob = selectedJob
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserProfile" {
            let vc = segue.destination as! UserProfileViewController
            vc.reqId = userId
            
        }
    }

}
