//
//  PostedViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// cell dance when delete is pressed
// change highlighted cell color
// swipe to select highlighted cell only


import UIKit

class PostedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user = PFUser.current()!
    var postedJobs = [PFObject]()
    var editJob = PFObject(className: "Job")
    var jobsToDelete = [PFObject]()
    var selectedJob = PFObject(className: "Job")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteJobs: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var logo: UILabel!
    
    // get rows selected for deleting and returns the job objects
    func getRowsToDelete() -> [PFObject] {
        var deleteRows = [PFObject]()
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                deleteRows.append(postedJobs[indexPath.row])
                
            }
        }
        return deleteRows
        
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            // run delete process if "Yes Delete" is selected
            for job in self.jobsToDelete {
                let id = job.objectId!
                // for loop within for loop to compare each row/job selected for deletion with the current list of posted jobs
                for postedJob in self.postedJobs {
                    if id == postedJob.objectId {
                        self.postedJobs.remove(at: (self.postedJobs.index(of: postedJob))!)
                        let query = PFQuery(className: "Job")
                        query.whereKey("objectId", equalTo: id)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if let objects = objects {
                                for object in objects {
                                    object.deleteInBackground(block: { (success, error) in
                                        if let error = error {
                                            self.errorAlert(title: "Error Deleting Job", message: error.localizedDescription)
                                            
                                        } else {
                                            self.tableView.reloadData()
                                            self.deleteJobs.setTitle("Delete x", for: UIControlState.normal)
                                            self.tableView.allowsMultipleSelection = false
                                            
                                        }
                                    })
                                    
                                }
                            }
                        })
                    }
                }
            }
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
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
                    // reset cell center to middle of view
                    cell.center.x = self.view.center.x
                    // pass selected job to segue
                    selectedJob = postedJobs[indexPath.row]
                    // then segue to select vc
                    performSegue(withIdentifier: "toSelect", sender: self)
                    
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // collect user's posted jobs from a query to "Job" class
        let userFid = user.object(forKey: "facebookId") as! String
        let query = PFQuery(className: "Job")
        query.whereKey("requesterFid", equalTo: userFid)
        query.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                if jobs.count > 0 {
                    for job in jobs {
                        self.postedJobs.append(job)
                    }
                    // reload data after async query
                    self.tableView.reloadData()
                } else {
                    self.emptyLabel.text = "You have not posted any jobs"
                    
                }
            }
        }
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        tableView.delegate = self
        tableView.dataSource = self
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
        tableView.addGestureRecognizer(pan)
        tableView.isUserInteractionEnabled = true
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func editJob(_ sender: Any) {
        if let index = tableView.indexPathForSelectedRow?.row {
            let selectedJob = postedJobs[index]
            // pass selected job to editJob segue
            editJob = selectedJob
            performSegue(withIdentifier: "toEditJob", sender: self)

        } else {
            errorAlert(title: "Select a job to edit", message: "You have not selected any jobs")
            
        }
    }
    
    @IBAction func triggerDelete(_ sender: Any) {
        
        // if "Delete" is active, start deletion process
        if deleteJobs.currentTitle == "Delete x" {
            tableView.allowsMultipleSelection = true
            deleteJobs.setTitle("Done x", for: UIControlState.normal)

        } else {
            // else if "Done" is active
            if deleteJobs.currentTitle == "Done x" {
                var jobTitles = ""
                // delete selected rows
                // get the array of PFObjects selected for deletion, could be empty if no selection was made
                jobsToDelete = getRowsToDelete()
                let deleteCount = jobsToDelete.count
                // if there were rows selected for deletion, display deleteAlert. Else dont show alert
                if deleteCount > 0 {
                    // delete jobs in Parse
                    for job in jobsToDelete {
                        let jobTitle = job.object(forKey: "title") as! String
                        jobTitles += jobTitle + " \n"
                    }
                    // deletes "object" in "objects" then reloads tableview, resets deleteButton title and stops allowing multiple selections
                    self.deleteAlert(title: "Are you sure you want to delete these jobs?", message: jobTitles)
                
                // if there are no rows selected for deletion, reset deleteButton title and stop allowing multiple selections
                } else {
                    deleteJobs.setTitle("Delete x", for: UIControlState.normal)
                    tableView.allowsMultipleSelection = false
                    
                }
            }
        }
    }
            
            
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postedJobs.count
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postedCell", for: indexPath) as! PostedTableViewCell
        let job = postedJobs[indexPath.row]
        let jobTitle = job.object(forKey: "title") as! String
        let jobCycle = job.object(forKey: "cycle") as! String
        let jobRate = job.object(forKey: "rate") as! String
        cell.postedTitle?.text = jobTitle
        cell.postedCycle?.text = "Cycle : " + jobCycle
        cell.postedRate?.text = "Rate : " + jobRate
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditJob" {
            let vc = segue.destination as! EditJobViewController
            vc.editJob = self.editJob

        }
        if segue.identifier == "toSelect" {
            let vc = segue.destination as! SelectViewController
            vc.selectedJob = self.selectedJob
            
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

}
