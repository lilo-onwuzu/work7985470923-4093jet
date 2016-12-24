//
//  MessageViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MesssageViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    var showMenu = false
    let user = PFUser.current()!
    var messageJobs = [PFObject]()
    var selectedJob = PFObject(className: "Job")
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var menuView: UIView!

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
                            selectedJob = messageJobs[index.row]
                            performSegue(withIdentifier: "toShowMessages", sender: self)
                            
                        }
                        // reset cell center to center of screen
                        cell.center.x = self.view.center.x
                        
                    }
                }
            }
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
        // query job class for list of jobs with userid as selectedUser
        let query = PFQuery(className: "Job")
        query.whereKey("selectedUser", equalTo: user.objectId!)
        query.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                if jobs.count > 0 {
                    for job in jobs {
                        self.messageJobs.append(job)
                        
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
    
    @IBAction func mainMenu(_ sender: Any) {
        if showMenu == false {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            menuView = vc.view
            let view = menuView.subviews[1]
            view.isHidden = true
            menuView.frame = CGRect(x: 0, y: 104, width: (0.8 * self.view.bounds.width), height: (self.view.bounds.height - 15))
            menuView.alpha = 0
            self.view.addSubview(menuView)
            UIView.transition(with: menuView,
                              duration: 0.25,
                              options: .curveEaseInOut,
                              animations: { self.menuView.alpha = 1 },
                              completion: nil)
            menuView.isHidden = false
            showMenu = true
            
        } else if showMenu == true {
            let view = self.view.subviews.last!
            view.removeFromSuperview()
            showMenu = false
            
        }
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
        // get images
        let reqId = job.object(forKey: "requesterId") as! String
        // fetch requestor image
        var requester = PFUser()
        do {
            requester = try PFQuery.getUserObject(withId: reqId)
            
        } catch _ {
            
        }
        let imageFile = requester.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                cell.reqImage.image = UIImage(data: imageData as Data)
                
            }
        }
        cell.myTableView = tableView
        if cell.ready {
            cell.selectedJob = job
            performSegue(withIdentifier: "toShowMessages", sender: self)
            
        }
        return cell
        
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
