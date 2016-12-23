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
    @IBOutlet weak var swipeIcon: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    
    func recenter () {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .transitionCrossDissolve,
                       animations: { self.swipeIcon.center.x -= 30 },
                       completion: nil)
    }
    
    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
        cellBack.layer.masksToBounds = true
        cellBack.layer.cornerRadius = 7
        viewProfile.layer.masksToBounds = true
        viewProfile.layer.cornerRadius = 7
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 35
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            // Configure the highlighted color for the selected state
            self.userName.textColor = UIColor.black
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.0,
                           options: .transitionCrossDissolve,
                           animations: { self.swipeIcon.center.x += 30 },
                           completion: { (success) in
                            self.recenter()
            })
        } else {
            self.userName.textColor = UIColor.white
            
        } 
    }

}
