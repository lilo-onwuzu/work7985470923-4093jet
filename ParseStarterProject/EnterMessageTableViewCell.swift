//
//  EnterMessageTableViewCell.swift
//
//  Created by mac on 12/22/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import UIKit

class EnterMessageTableViewCell: UITableViewCell {

    var selectedJob = PFObject(className: "Job")

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
            let dict = NSDictionary()
            dict.setValue(enteredText, forKey: "requester")
            var messages = selectedJob.object(forKey: "messages") as! Array<Any>
            messages.append(dict)
            print(messages)
            
        }
    }

}
