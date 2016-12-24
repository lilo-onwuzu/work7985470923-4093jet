//
//  ReceivedTableViewCell.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ReceivedTableViewCell: UITableViewCell {

    @IBOutlet weak var receivedTitle: UILabel!
    @IBOutlet weak var receivedRate: UILabel!
    @IBOutlet weak var receivedCycle: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var receivedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        receivedLabel.layer.masksToBounds = true
        receivedLabel.layer.cornerRadius = 7
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 45
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the highlighted color for the selected state
        if selected {
            self.receivedTitle.textColor = UIColor.black
            
        } else {
            self.receivedTitle.textColor = UIColor.white

        }
    }

}
