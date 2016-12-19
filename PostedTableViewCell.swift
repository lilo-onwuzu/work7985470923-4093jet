//
//  PostedTableViewCell.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// add swipe icon to highlighted cell


import UIKit

class PostedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postedTitle: UILabel!
    @IBOutlet weak var postedCycle: UILabel!
    @IBOutlet weak var postedRate: UILabel!
    @IBOutlet weak var postedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postedLabel.layer.masksToBounds = true
        postedLabel.layer.cornerRadius = 7
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the highlighted color for the selected state
        if selected {
            self.postedTitle.textColor = UIColor.black
            self.postedCycle.textColor = UIColor.black
            self.postedRate.textColor = UIColor.black
            
        } else {
            self.postedTitle.textColor = UIColor.white
            self.postedCycle.textColor = UIColor.white
            self.postedRate.textColor = UIColor.white
            
        }
    }

}
