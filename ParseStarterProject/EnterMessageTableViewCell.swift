//
//  EnterMessageTableViewCell.swift
//
//  Created by mac on 12/22/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class EnterMessageTableViewCell: UITableViewCell, UITextFieldDelegate {

    var selectedJob = PFObject(className: "Job")
    var myTableView = UITableView()

    @IBOutlet weak var entertextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    func sendText() {
        if entertextField.text! != "" {
            let enteredText = entertextField.text!
            let newMessage: [String : String] = ["req" : enteredText]
            selectedJob.add(newMessage, forKey: "messages")
            selectedJob.saveInBackground()
            myTableView.reloadData()
            entertextField.text = ""
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        entertextField.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func send(_ sender: UIButton) {
        sendText()
        
    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
        
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendText()
        return true
        
    }
    
}
