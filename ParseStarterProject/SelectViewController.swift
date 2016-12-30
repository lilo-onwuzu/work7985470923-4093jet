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
    
    func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedJob)
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
        showSelectedRow(index: indexPath.row, swipeButton: cell.swipeIcon, selectLabel: cell.selectLabel)
        cell.myTableView = tableView
        // once cell is swipped right, cell.ready becomes true and the tableview is reloaded which causes this to load too
        if cell.ready {
            print("ready")
            selectedJob.setValue(users[indexPath.row], forKey: "selectedUser")
            // init messaging when match is made and send message alert to user
            let introValue = "Congratulations! " + requesterName + " picked you for the job. Connect with " + requesterName + " here"
            let introMessage: [String : String] = ["intro" : introValue]
            var messages = [NSDictionary]()
            messages.append(introMessage as NSDictionary)
            selectedJob.setValue(messages, forKey: "messages")
            selectedJob.saveInBackground()
            
        }
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
