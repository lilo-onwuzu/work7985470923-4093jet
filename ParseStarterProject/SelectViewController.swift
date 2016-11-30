//
//  SelectViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// change cell type when match is made
// pull to refresh
// change highlighted cell color
// swipe to select highlighted cell only


import UIKit

class SelectViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    var selectedJob = PFObject(className: "Job")
    var users = [String]()
    var userId = ""
    var requesterName = ""
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
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
            // xFromCenter is +ve if pan is to the right and -ve is pan is to the left
            if gesture.state == UIGestureRecognizerState.ended {
                if translation.x > 100 {
                    // reset cell center to middle of view
                    cell.center.x = self.view.center.x
                    // swipe right sets selected user value
                    selectedJob.setValue(users[indexPath.row], forKey: "selectedUser")
                    // init messaging when match is made and send message alert to user
                    var messages = [Dictionary<String, String>]()
                    let dict = ["intro" :  "Congratulations! " + requesterName + " picked you for the job. Connect with " + requesterName + " here"]
                    messages.append(dict)
                    selectedJob.setValue(messages, forKey: "messages")
                    selectedJob.saveInBackground()
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        users = selectedJob.object(forKey: "userAccepted") as! [String]
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
        tableView.addGestureRecognizer(pan)
        tableView.isUserInteractionEnabled = true
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func viewUser(_ sender: UIButton) {
        if let id = tableView.indexPathForSelectedRow?.row {
            // pass user id to segue then perform segue
            userId = users[id]
            performSegue(withIdentifier: "toUserProfile", sender: self)
        
        } else {
            errorAlert(title: "Invalid Selection", message: "Select a user to view their profile")
            
        }
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
        
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserAcceptedTableViewCell
        // fetch user name and image and display
        do {
            let user = try PFQuery.getUserObject(withId: users[indexPath.row])
            let firstName = user.object(forKey: "first_name") as! String
            requesterName = firstName
            let lastName = user.object(forKey: "last_name") as! String
            cell.userName.text = firstName + " " + lastName
            cell.userName.sizeToFit()
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
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserProfile" {
            let vc = segue.destination as! UserProfileViewController
            vc.reqId = userId
            
        }
    }

}
