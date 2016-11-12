//
//  PostedTableViewCell.swift
//  ParseStarterProject
//
//  Created by mac on 11/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostedTableViewCell: UITableViewCell {

    @IBOutlet weak var postedTitle: UILabel!
    @IBOutlet weak var postedRate: UILabel!
    @IBOutlet weak var postedCycle: UILabel!
    @IBOutlet weak var postedDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
