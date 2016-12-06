//
//  UserAcceptedTableViewCell.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class UserAcceptedTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var viewProfile: UIButton!
    @IBOutlet weak var cellBack: UILabel!
    
    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
        cellBack.layer.masksToBounds = true
        cellBack.layer.cornerRadius = 7
        viewProfile.layer.masksToBounds = true
        viewProfile.layer.cornerRadius = 7
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 28

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            // show swipe animation
            viewProfile.isHidden = false
            self.userName.textColor = UIColor.black
            
        } else {
            self.userName.textColor = UIColor.white

        }
    }

}
