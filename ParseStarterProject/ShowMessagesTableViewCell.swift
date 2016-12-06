//
//  ShowMessagesTableViewCell.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ShowMessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            self.message.textColor = UIColor.black
            
        } else {
            self.message.textColor = UIColor.white
            
        }
    }
    
    @IBAction func send(_ sender: Any) {
        
        
    }

}
