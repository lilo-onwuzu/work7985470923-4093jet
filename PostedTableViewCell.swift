//
//  PostedTableViewCell.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class PostedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postedTitle: UILabel!
    @IBOutlet weak var postedCycle: UILabel!
    @IBOutlet weak var postedRate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the highlighted color for the selected state
        let colorView = UIView()
        colorView.backgroundColor = UIColor.darkGray
        self.selectedBackgroundView = colorView
        if selected {
            // add swipe icon to highlighted cell

        }
    }

}
