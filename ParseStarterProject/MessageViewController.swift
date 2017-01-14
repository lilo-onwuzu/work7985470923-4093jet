//
//  MessageViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MesssageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var showMenu = true
    let user = PFUser.current()!
    var postedJobs = [PFObject]()
    var matchedJobs = [PFObject]()
    var selectedJob = PFObject(className: "Job")
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuView: UIView!

    func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
        
    }
    
    func displayMenu() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        // place home view in menuView
        menuView = vc.view
        let view = menuView.subviews[1]
        // hide logo to prevent logo repeat
        view.isHidden = true
        self.view.addSubview(menuView)
        // size menuView
        let xOfView = self.view.bounds.width
        let yOfView = self.view.bounds.height
        let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
        menuView.frame = rect
        // menuView is hidden in viewDidLoad, now it is displayed
        self.menuView.isHidden = false
        showMenu = false

    }
    
    // hide menuView on viewDidAppear so if user presses back to return to this view, menuView is hidden
    func removeMenu() {
        menuView.isHidden = true
        showMenu = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        tableView.delegate = self
        tableView.dataSource = self
        menuView.isHidden = true
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        
        // query job class for list of jobs with userid as selectedUser
        let querySelected = PFQuery(className: "Job")
        querySelected.whereKey("selectedUser", equalTo: user.objectId!)
        querySelected.findObjectsInBackground { (selectedForJobs, error) in
            if let selectedForJobs = selectedForJobs {
                for selectedForjob in selectedForJobs {
                    self.matchedJobs.append(selectedForjob)
                    self.tableView.reloadData()
                
                }
            }
        }
        
        // query job class for list of posted jobs
        let queryAccepted = PFQuery(className: "Job")
        queryAccepted.whereKey("requesterId", equalTo: self.user.objectId!)
        queryAccepted.findObjectsInBackground { (postedJobs, error) in
            if let postedJobs = postedJobs {
                for postedJob in postedJobs {
                    let selectedUser = postedJob.object(forKey: "selectedUser") as! String
                    if selectedUser != "" {
                        self.postedJobs.append(postedJob)
                        // reload data after async query to fill tableView
                        self.tableView.reloadData()
                   
                    }
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //tableView.reloadData()
        removeMenu()
        
    }
    
    // viewDidLayoutSubviews() runs each time layout changes
    override func viewDidLayoutSubviews() {
        if UIDevice.current.orientation.isLandscape {
            // resize menuView (if present in view i.e if menuView is already being displayed) whenever orientation changes. this calculates the variable "rect" based on the new bounds
            for view in self.view.subviews {
                if view.tag == 2 {
                    let xOfView = self.view.bounds.width
                    let yOfView = self.view.bounds.height
                    let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
                    menuView.frame = rect
                    
                }
            }
        } else {
            // resize menuView for portrait
            for view in self.view.subviews {
                if view.tag == 2 {
                    let xOfView = self.view.bounds.width
                    let yOfView = self.view.bounds.height
                    let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
                    menuView.frame = rect
                    
                }
            }
        }
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        if showMenu {
            displayMenu()
            
        } else {
            removeMenu()
            
        }
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return postedJobs.count

        } else {
            return matchedJobs.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Jobs I Posted"
            
        } else {
            return "Jobs I've Been Matched With"
            
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! MessageTableViewCell
            
            // if cell.ready is true, cell has been swiped and ready for segue to showMessages vc
            if cell.ready {
                cell.ready = false
                selectedJob = postedJobs[indexPath.row]
                // save user/requester message count whenever cell is swiped right and ShowMessagesTableView is instantiated so we can use it in the future
                cell.getCount()
                performSegue(withIdentifier: "toShowMessages", sender: self)
                
            }
            
            // give postCell details
            let job = postedJobs[indexPath.row]
            let jobTitle = job.object(forKey: "title") as! String
            cell.messageTitle.text = jobTitle
            // pass tableView to cell so we can reload tableview from within cell
            cell.myTableView = tableView
            // get images
            let reqId = job.object(forKey: "requesterId") as! String
            // fetch user's image
            var requester = PFObject(className: "User")
            let query: PFQuery = PFUser.query()!
            query.whereKey("objectId", equalTo: reqId)
            query.findObjectsInBackground { (users, error) in
                if let users = users {
                    requester = users[0]
                    let imageFile = requester.object(forKey: "image") as! PFFile
                    imageFile.getDataInBackground { (data, error) in
                        if let data = data {
                            let imageData = NSData(data: data)
                            cell.reqImage.image = UIImage(data: imageData as Data)
                            
                        }
                    }
                }
            }
            cell.selectedJob = job
            // newCount() subtracts the current message count from the previous messageCount to get number of new messages
            cell.newCount()
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as! MessageTableViewCell
            
            // if cell.ready is true, cell has been swiped and ready for segue to showMessages vc
            if cell.ready {
                cell.ready = false
                selectedJob = matchedJobs[indexPath.row]
                // save user/requester message count whenever cell is swiped right and ShowMessagesTableView is instantiated so we can use it in the future
                cell.getCount()
                performSegue(withIdentifier: "toShowMessages", sender: self)
                
            }
            
            // give matchCell details
            let job = matchedJobs[indexPath.row]
            let jobTitle = job.object(forKey: "title") as! String
            cell.messageTitle.text = jobTitle
            cell.myTableView = tableView
            // fetch requestor image
            let reqId = job.object(forKey: "requesterId") as! String
            var requester = PFObject(className: "User")
            let query: PFQuery = PFUser.query()!
            query.whereKey("objectId", equalTo: reqId)
            query.findObjectsInBackground { (users, error) in
                if let users = users {
                    requester = users[0]
                    let imageFile = requester.object(forKey: "image") as! PFFile
                    imageFile.getDataInBackground { (data, error) in
                        if let data = data {
                            let imageData = NSData(data: data)
                            cell.reqImage.image = UIImage(data: imageData as Data)
                            
                        }
                    }
                }
            }
            cell.selectedJob = job
            // newCount() subtracts the current message count from the previous messageCount to get number of new messages
            cell.newCount()
            
            return cell
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuView.isHidden = true
        showMenu = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowMessages" {
            let vc = segue.destination as! ShowMessagesViewController
            vc.selectedJob = selectedJob

        }
    }
    
}
