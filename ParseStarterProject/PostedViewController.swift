//
//  PostedViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import UIKit

class PostedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user = PFUser.current()!
    var postedJobs = [PFObject]()
    var confirmDelete = Bool()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteJobs: UIButton!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
        
    // verifies delete by setting var confirmDelete to true
    func deleteAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            // set confirm to true to run PFUser delete
            self.confirmDelete = true
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // collect user's posted jobs from a query to "Job" class
        let userFid = user.object(forKey: "facebookId") as! String
        let query = PFQuery(className: "Job")
        query.whereKey("requesterFid", equalTo: userFid)
        query.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                for job in jobs {
                    self.postedJobs.append(job)
                }
                // reload data after async query
                self.tableView.reloadData()
                
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func editJob(_ sender: Any) {
        if let index = tableView.indexPathForSelectedRow?.row {
            let editJob = postedJobs[index]
            // pass selected job to editJob segue
            print(editJob)
            
        }
    }
    
    @IBAction func triggerDelete(_ sender: Any) {
        
        var jobsToDelete = [PFObject]()
        
        // allows user to select one or more rows once this button is pressed while "Select" is active
        if deleteJobs.currentTitle == "Delete x" {
            deleteJobs.setTitle("Select", for: UIControlState.normal)

        } else {
            if deleteJobs.currentTitle == "Select" {
                tableView.allowsMultipleSelection = true
                // get the array of PFObjects selected for deletion, could be empty
                jobsToDelete = getRowsToDelete()
                let deleteCount = jobsToDelete.count
                // if there were rows selected for deletion, do this. Else dont show alert to confirm delete
                if deleteCount > 0 {
                    var jobTitles = ""
                    for job in jobsToDelete {
                        let jobTitle = job.object(forKey: "title") as! String
                        jobTitles += jobTitle + " \n"
                    
                    }
                    deleteAlert(title: "Are you sure you want to delete these jobs?", message: jobTitles)
                    deleteJobs.setTitle("Done", for: UIControlState.normal)
                
                } else {
                    deleteJobs.setTitle("Delete x", for: UIControlState.normal)
                    tableView.allowsMultipleSelection = false
                    
                }
            } else {
                if deleteJobs.currentTitle == "Done" {
                    // reduce tpt by placing confirmDelete() here so it is only run in this thread
                    if confirmDelete {
                        // delete jobs in Parse
                        for job in jobsToDelete {
                            let id = job.objectId!
                            for postedJob in postedJobs {
                                if id == postedJob.objectId {
                                    postedJobs.remove(at: (postedJobs.index(of: postedJob))!)
                                    let query = PFQuery(className: "Job")
                                    query.whereKey("objectId", equalTo: id)
                                    query.findObjectsInBackground(block: { (objects, error) in
                                        if let objects = objects {
                                            for object in objects {
                                                object.deleteInBackground(block: { (success, error) in
                                                    if let error = error {
                                                        self.errorAlert(title: "Error Deleting Job", message: error.localizedDescription)
                                                        
                                                    } else {
                                                        self.deleteJobs.setTitle("Delete x", for: UIControlState.normal)
                                                        // reload tableView
                                                        print(self.postedJobs)
                                                        self.tableView.reloadData()
                                                        // self.deleteJobs.setTitle("Delete", for: UIControlState.normal)
                                                        self.tableView.allowsMultipleSelection = false
                                                        
                                                    }
                                                })
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
