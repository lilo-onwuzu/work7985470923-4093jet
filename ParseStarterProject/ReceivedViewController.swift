//
//  ReceivedTableViewController.swift
//
//  Created by mac on 11/10/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// change highlighted cell color
// number of cells may become unpredictable when number of posted jobs is large. execute on main thread


import UIKit

class ReceivedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user = PFUser.current()!
    var receivedJobs = [PFObject]()
    var ready = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    func getJobs() -> Int {
        var received = Int()
        // query job class for list of jobs with userid as selectedUser
        let query = PFQuery(className: "Job")
        query.whereKey("selectedUser", equalTo: user.objectId!)
        query.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                received = jobs.count
                self.ready = true
                
            }
        }
        return received
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3

    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func statusUpdate(_ sender: Any) {
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receivedCell", for: indexPath) as! ReceivedTableViewCell
        if receivedJobs.count > 0 {
            for job in receivedJobs {
                let reqId = job.object(forKey: "requesterId") as! String
                // fetch requestor image and display
                do {
                    let user = try PFQuery.getUserObject(withId: reqId)
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
                let jobTitle = job.object(forKey: "title") as! String
                let jobCycle = job.object(forKey: "cycle") as! String
                let jobRate = job.object(forKey: "rate") as! String
                cell.receivedTitle.text = jobTitle
                cell.receivedCycle.text = "Cycle : " + jobCycle
                cell.receivedRate.text = "Rate : " + jobRate
                self.tableView.reloadData()
                
            }
        } else {
            self.emptyLabel.text = "You have not posted any jobs"
            
        }
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
