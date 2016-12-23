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
    @IBOutlet weak var postedLabel: UILabel!
    @IBOutlet weak var swipeIcon: UIButton!
    @IBOutlet weak var swipeLabel: UILabel!
    
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
            swipeIcon.isHidden = false
            swipeLabel.isHidden = false
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
            self.postedTitle.textColor = UIColor.white
            swipeIcon.isHidden = true
            swipeLabel.isHidden = true
            
        }
    }

}
