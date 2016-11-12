//
//  AcceptedTableViewCell.swift
//  ParseStarterProject
//
//  Created by mac on 11/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class AcceptedTableViewCell: UITableViewCell {

    @IBOutlet weak var acceptedTitle: UILabel!
    @IBOutlet weak var acceptedRate: UILabel!
    @IBOutlet weak var acceptedCycle: UILabel!
    @IBOutlet weak var acceptedDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
