//
//  ReceivedTableViewController.swift
//
//  Created by mac on 11/10/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ReceivedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var showMenu = false
    var user = PFUser.current()!
    var receivedJobs = [PFObject]()
    var refresher: UIRefreshControl!
    
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
        return receivedJobs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receivedCell", for: indexPath) as! ReceivedTableViewCell
        let job = receivedJobs[indexPath.row]
        // get images
        //let reqId = job.object(forKey: "requesterId") as! String
        // fetch requestor image
        //query.findObjectsInBackground { (users, error) in
          //  if let users = users {
            //    print(users)
            //} else {
              //  print("error")
            //}
        //}
        //let imageFile = requester.object(forKey: "image") as! PFFile
        //imageFile.getDataInBackground { (data, error) in
            //if let data = data {
                //let imageData = NSData(data: data)
                //cell.userImage.image = UIImage(data: imageData as Data)
                
            //}
        //}
        let jobTitle = job.object(forKey: "title") as! String
        let jobCycle = job.object(forKey: "cycle") as! String
        let jobRate = job.object(forKey: "rate") as! String
        cell.receivedTitle.text = jobTitle
        cell.receivedCycle.text = "Cycle : " + jobCycle
        cell.receivedRate.text = "Rate : " + jobRate
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
