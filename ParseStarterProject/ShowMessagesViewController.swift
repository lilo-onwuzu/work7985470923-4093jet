//
//  ShowMessagesViewController.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


// pull to refresh

import UIKit

class ShowMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selectedJob = PFObject(className: "Job")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3

    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let messages = selectedJob.object(forKey: "messages") as! Array<Any>
            return messages.count
            
        } else {
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ShowMessagesTableViewCell
            let messages = selectedJob.object(forKey: "messages") as! Array<Any>
            for message in messages {
                let dictionary = message as! NSDictionary
                let row = dictionary.object(forKey: "intro") as! String
                cell.message.text = row
                cell.message.sizeToFit()
                
            }
            cell.sizeToFit()
            return cell
            
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EnterMessageTableViewCell
            cell.selectedJob = selectedJob
            return cell
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
