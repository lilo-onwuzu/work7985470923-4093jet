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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        let colorView = UIView()
        colorView.backgroundColor = UIColor.darkGray
        self.selectedBackgroundView = colorView
        
    }

}
