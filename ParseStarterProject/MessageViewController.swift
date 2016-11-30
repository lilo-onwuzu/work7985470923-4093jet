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
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
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
            if gesture.state == UIGestureRecognizerState.ended {
                if translation.x > 100 {
                    // reset cell center to middle of view
                    cell.center.x = self.view.center.x
                    // pass selected job to segue
                    selectedJob = messageJobs[indexPath.row]
                    // then segue to select vc
                    performSegue(withIdentifier: "toShowMessages", sender: self)
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
        tableView.addGestureRecognizer(pan)
        tableView.isUserInteractionEnabled = true
        // query "Job" where user is selectedUser or requesterId
        let query = PFQuery(className: "Job")
        query.whereKey("selectedUser", equalTo: user.objectId!)
        query.whereKey("requesterId", equalTo: user.objectId!)
        query.findObjectsInBackground { (jobs, error) in
            if let error = error {
                self.errorAlert(title: "Error getting messages", message: error.localizedDescription)
                
            } else if let jobs = jobs {
                self.messageJobs = jobs
                
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageJobs.count
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        let job = messageJobs[indexPath.row]
        cell.jobTitle.text = job.object(forKey: "title") as? String
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMessageList" {
            let vc = segue.destination as! ShowMessagesViewController
            vc.selectedJob = selectedJob
            
        }
    }
    
}
