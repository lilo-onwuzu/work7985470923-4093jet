//
//  EnterMessageTableViewCell.swift
//
//  Created by mac on 12/22/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class EnterMessageTableViewCell: UITableViewCell {

    var selectedJob = PFObject(className: "Job")
    var myTableView = UITableView()

    @IBOutlet weak var entertextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func send(_ sender: UIButton) {
        if entertextField.text! != "" {
            let enteredText = entertextField.text!
            let newMessage: [String : String] = ["req" : enteredText]
            selectedJob.add(newMessage, forKey: "messages")
            selectedJob.saveInBackground()
            myTableView.reloadData()
            entertextField.text = ""
            
        }
    }

}
