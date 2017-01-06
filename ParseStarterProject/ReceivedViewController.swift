//
//  ReceivedTableViewController.swift
//
//  Created by mac on 11/10/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ReceivedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var showMenu = true
    var user = PFUser.current()!
    var receivedJobs = [PFObject]()
    var refresher: UIRefreshControl!
    var jobRequesterId = ""
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    
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
        // query job class for list of jobs with userid as selectedUser
        let query = PFQuery(className: "Job")
        query.whereKey("selectedUser", equalTo: user.objectId!)
        query.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                if jobs.count > 0 {
                    for job in jobs {
                        self.receivedJobs.append(job)
                        
                    }
                    // reload data after async query
                    self.tableView.reloadData()
                } else {
                    self.emptyLabel.isHidden = false
                    
                }
            }
        }
        menuView.isHidden = true
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)

    }

    override func viewDidLayoutSubviews() {
        if UIDevice.current.orientation.isLandscape {
            for view in self.view.subviews {
                // viewDidLayoutSubviews() runs each time layout changes
                // resize menuView (if present in view i.e if menuView is already being displayed) whenever orientation changes. this calculates the variable "rect" based on the new bounds
                if view.tag == 2 {
                    let xOfView = self.view.bounds.width
                    let yOfView = self.view.bounds.height
                    let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
                    menuView.frame = rect
                    
                }
            }
        } else {
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
    
    // hide menuView on viewDidAppear so if user presses back to return to thois view, menuView is hidden
    override func viewDidAppear(_ animated: Bool) {
        menuView.isHidden = true
        showMenu = true
        
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        if showMenu {
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
            self.showMenu = false

        } else {
            menuView.isHidden = true
            showMenu = true
    
        }
    }

    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedJobs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receivedCell", for: indexPath) as! ReceivedTableViewCell
        if cell.ready {
            cell.ready = false
            let selectedJob = receivedJobs[indexPath.row]
            jobRequesterId = selectedJob.object(forKey: "requesterId") as! String
            performSegue(withIdentifier: "toProfile", sender: self)
            
        }
        let job = receivedJobs[indexPath.row]
        // get images
        let reqId = job.object(forKey: "requesterId") as! String
        // fetch requestor image
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
                        cell.userImage.image = UIImage(data: imageData as Data)

                    }
                }
            }
        }
        let jobTitle = job.object(forKey: "title") as! String
        let jobCycle = job.object(forKey: "cycle") as! String
        let jobRate = job.object(forKey: "rate") as! String
        cell.receivedTitle.text = jobTitle
        cell.receivedCycle.text = jobCycle
        cell.receivedRate.text = "$" + jobRate
        cell.myTableView = tableView
        return cell
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuView.isHidden = true
        showMenu = true

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let vc = segue.destination as! UserProfileViewController
            vc.reqId = self.jobRequesterId
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
