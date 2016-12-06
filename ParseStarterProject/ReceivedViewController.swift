//
//  ReceivedTableViewController.swift
//
//  Created by mac on 11/10/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ReceivedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user = PFUser.current()!
    var receivedJobs = [PFObject]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
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
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func statusUpdate(_ sender: Any) {
    
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
        
//        let reqId = job.object(forKey: "requesterId") as! String
////             fetch requestor image
//        var requester = PFUser()
//        do {
//                requester = try PFQuery.getUserObject(withId: reqId)
//            
//            } catch _ {
//                
//            }
//        let imageFile = requester.object(forKey: "image") as! PFFile
//        imageFile.getDataInBackground { (data, error) in
//            if let data = data {
//                let imageData = NSData(data: data)
//                cell.userImage.image = UIImage(data: imageData as Data)
//                
//            }
//        }

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
