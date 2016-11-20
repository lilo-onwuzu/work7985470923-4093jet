//
//  AcceptedTableViewController.swift
//
//  Created by mac on 11/10/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// show succesfull match indicator
// swipe right to direct to message view


import UIKit

class AcceptedTableViewController: UITableViewController {

    var user = PFUser.current()!
    var acceptedJobIds = [String]()
    
    @IBOutlet weak var listTitle: UILabel!
    @IBOutlet weak var listCycle: UILabel!
    @IBOutlet weak var listRate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedJobIds = user.object(forKey: "accepted") as! [String]
        // preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acceptedJobIds.count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "acceptedCell", for: indexPath) as! AcceptedTableViewCell
        // query Job class for list of user's accepted jobs
        let query = PFQuery(className: "Job")
        query.whereKey("objectId", equalTo: acceptedJobIds[(indexPath as NSIndexPath).row])
        query.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                for job in jobs {
                    let jobTitle = job.object(forKey: "title") as! String
                    let jobCycle = job.object(forKey: "cycle") as! String
                    let jobRate = job.object(forKey: "rate") as! String
                    cell.acceptedTitle?.text = jobTitle
                    cell.acceptedCycle?.text = "Cycle : " + jobCycle
                    cell.acceptedRate?.text = "Rate : " + jobRate
                    self.tableView.reloadData()

                }
            }
        }
        
        return cell
        
    }
}
