//
//  AcceptedTableViewController.swift
//
//  Created by mac on 11/10/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class AcceptedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user = PFUser.current()!
    var acceptedJobIds = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    func drag(gesture: UIPanGestureRecognizer) {
        // measure the translation in pan
        let translation = gesture.translation(in: self.view)
        let indexPath = tableView.indexPathForSelectedRow
        // "if let" conditional checks if a row is selected
        if let indexPath = indexPath {
            let cell = tableView.cellForRow(at: indexPath)!
            cell.center.x = self.view.center.x + translation.x
            // xFromCenter is +ve if pan is to the right and -ve is pan is to the left
            if gesture.state == UIGestureRecognizerState.ended {
                if translation.x > 100 {
                    print("hello")
                    
                } else if translation.x < -100 {
                    print("hi")
                    
                }
                cell.center.x = self.view.center.x
                // segue to select vc
                performSegue(withIdentifier: "toPay", sender: self)
                // pass selected job to segue
                
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedJobIds = user.object(forKey: "accepted") as! [String]
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
        tableView.addGestureRecognizer(pan)
        tableView.isUserInteractionEnabled = true
        
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
        return acceptedJobIds.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
