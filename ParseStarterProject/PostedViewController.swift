//
//  PostedViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class PostedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var showMenu = false
    var user = PFUser.current()!
    // all user's posted jobs
    var postedJobs = [PFObject]()
    // saves selected job(s) so it can be deleted
    var jobsToDelete = [PFObject]()
    // saves selected job so it can be passed along before segue to edit vc
    var editJob = PFObject(className: "Job")
    // saves selected job so it can be passed along before segue to select vc
    var selectedJob = PFObject(className: "Job")
    var deleting = false
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteJobs: UIButton!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    
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
        
        // add alert action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        // present
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add alert action
        alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        // add alert action
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
                                            // reload table after deleting cells
                                            self.tableView.reloadData()
                                            // remove "DELETE SELECTED" label next to delete button
                                            self.deleteLabel.isHidden = true
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
    
    func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()

    }
    
    func displayMenu() {
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
        
    }
    
    // hide menuView on viewDidAppear so if user presses back to return to this view, menuView is hidden. showMenu prevents the need for a double tap before menuView can be displayed again
    func removeMenu() {
        menuView.isHidden = true
        showMenu = true
        
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
                    self.emptyLabel.isHidden = false

                }
            }
        }
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        tableView.delegate = self
        tableView.dataSource = self
        menuView.isHidden = true
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        removeMenu()
        // reload tableView to remove gesture recognizers
        tableView.reloadData()
        
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        if showMenu {
            displayMenu()

        } else {
            removeMenu()
        
        }
    }

    @IBAction func editJob(_ sender: Any) {
        if let index = tableView.indexPathForSelectedRow?.row {
            // pass selected job to editJob segue once editJob is clicked
            editJob = postedJobs[index]
            performSegue(withIdentifier: "toEditJob", sender: self)

        // if no jobs are selected, show error/guide
        } else {
            errorAlert(title: "Select a job to edit", message: "You have not selected any jobs")
            
        }
    }
    
    @IBAction func triggerDelete(_ sender: Any) {
        // if deleting is in process
        if deleting {
            deleteLabel.isHidden = true
            deleting = false
            var jobTitles = ""
            
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
                
            }
            tableView.allowsMultipleSelection = false
            
        } else {
            deleteLabel.isHidden = false
            tableView.allowsMultipleSelection = true
            // start animating cells and activate delete trigger "deleting"
            deleting = true
  
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
        
        // this performs segue when cell is swiped tableview is reloaded and this function terminates here
        if cell.ready {
            // reset ready variable
            cell.ready = false
            // save selectedJon for select vc
            selectedJob = postedJobs[cell.selectedRow]
            performSegue(withIdentifier: "toSelect", sender: self)
            
        }
        
        // get user's images and other cell details
        let imageFile = user.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                cell.userImage.image = UIImage(data: imageData as Data)
                
            }
        }
        let job = postedJobs[indexPath.row]
        let jobTitle = job.object(forKey: "title") as! String
        let jobCycle = job.object(forKey: "cycle") as! String
        let jobRate = job.object(forKey: "rate") as! String
        cell.postedTitle?.text = jobTitle
        cell.postedCycle?.text = jobCycle
        cell.postedRate?.text = "$" + jobRate
        // return some other variables needed for operations within the respective cells for instance, tableView is given to cell to allow us to reload the tableview from inside cell
        cell.myTableView = tableView
        
        return cell
        
    }
    
    //  touch anywhere to hide menuView. showMenu prevents the need for a double tap before menuView can be displayed again
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeMenu()

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
