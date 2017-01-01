//
//  MessageViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MesssageViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    let user = PFUser.current()!
    var messageJobs = [PFObject]()
    var selectedJob = PFObject(className: "Job")
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var tableView: UITableView!
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
        let querySelected = PFQuery(className: "Job")
        querySelected.whereKey("selectedUser", equalTo: user.objectId!)
        querySelected.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                for job in jobs {
                    self.messageJobs.append(job)
                    self.tableView.reloadData()
                    // query job class for list of posted jobs
                    let queryAccepted = PFQuery(className: "Job")
                    queryAccepted.whereKey("requesterId", equalTo: self.user.objectId!)
                    queryAccepted.findObjectsInBackground { (jobs, error) in
                        if let jobs = jobs {
                            if jobs.count > 0 {
                                for job in jobs {
                                    if !self.messageJobs.contains(job) {
                                        self.messageJobs.append(job)

                                        if self.messageJobs.count > 0 {
                                            // reload data after async query to fill tableView
                                            self.tableView.reloadData()
                                        } else {
                                            self.emptyLabel.isHidden = false
                                        
                                        }
                                    }
                                }
                            } else {
                                self.emptyLabel.isHidden = false
                                    
                            }
                        }
                    }
                }
            }
        }
        menuView.isHidden = true
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        menuView.isHidden = true
        
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        // place home view in menuView
        menuView = vc.view
        let view = menuView.subviews[1]
        // hide logo to prevent logo repeat
        view.isHidden = true
        self.view.addSubview(menuView)
        // menuView is hidden in viewDidLoad, now it is displayed
        UIView.transition(with: menuView,
                          duration: 2,
                          options: .transitionFlipFromRight,
                          animations: { self.menuView.isHidden = false },
                          completion: nil)
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageJobs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        let job = messageJobs[indexPath.row]
        let jobTitle = job.object(forKey: "title") as! String
        cell.messageTitle.text = jobTitle
        cell.myTableView = tableView
        if cell.ready {
            selectedJob = messageJobs[indexPath.row]
            performSegue(withIdentifier: "toShowMessages", sender: self)
            
        }
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
                        cell.reqImage.image = UIImage(data: imageData as Data)
                        
                    }
                }
            }
        }
        return cell
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuView.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowMessages" {
            let vc = segue.destination as! ShowMessagesViewController
            vc.selectedJob = selectedJob
            
        }
    }
    
}
