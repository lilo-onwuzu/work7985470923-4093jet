//
//  ShowMessagesViewController.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ShowMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selectedJob = PFObject(className: "Job")
    var refresher: UIRefreshControl!
    var UITableViewAutomaticDimension = CGFloat()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    
    func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        jobTitle.text = selectedJob.object(forKey: "title") as? String

    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let messages = selectedJob.object(forKey: "messages") as! [NSDictionary]
            return messages.count
            
        } else {
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
            
        } else {
            return 50
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ShowMessagesTableViewCell
            let messages = selectedJob.object(forKey: "messages") as! [NSDictionary]
            if indexPath.row == 0 {
                let dictionary = messages[0]
                let introMessage = dictionary.object(forKey: "intro") as! String
                cell.message.text = introMessage
                
            } else {
                let dictionary = messages[indexPath.row]
                let message = dictionary.object(forKey: "req") as! String
                cell.message.text = message
                cell.message.sizeToFit()
                
            }
            return cell
            
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EnterMessageTableViewCell
            cell.selectedJob = selectedJob
            cell.myTableView = tableView
            return cell
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
