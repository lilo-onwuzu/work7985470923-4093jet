//
//  ShowMessagesViewController.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


// first message not displaying
// pull to refresh

import UIKit

class ShowMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selectedJob = PFObject(className: "Job")
    var messages = [Dictionary<String, String>]()
    
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
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages = selectedJob.object(forKey: "messages") as! [Dictionary<String, String>]
        return messages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ShowMessagesTableViewCell
        cell.message.text = messages[indexPath.row].description
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
