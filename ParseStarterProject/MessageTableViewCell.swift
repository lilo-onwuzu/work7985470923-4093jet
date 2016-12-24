//
//  MessageTableViewCell.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MessageTableViewCell: UITableViewCell {

    var selectedJob = PFObject(className: "Job")
    var myTableView = UITableView()
    var ready = false
    
    @IBOutlet weak var reqImage: UIImageView!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var swipeIcon: UIButton!
    @IBOutlet weak var connectLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func recenter () {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .transitionCrossDissolve,
                       animations: { self.swipeIcon.center.x -= 30 },
                       completion: nil)
    }
    
    // drag function is called continuosly from start to end of a pan
    func dragged (gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.contentView)
        // continue executing dragged() function if pan is to the right, if not, do nothing, function terminates
        if translation.x > 0 {
            self.center.x = self.center.x + translation.x
            // once pan gesture ends, if selected cell , pass job in highlighted cell to selectVC, perform segue
            if gesture.state == UIGestureRecognizerState.ended {
                if self.center.x > (self.bounds.width/2) {
                    ready = true
                    // reload tableView to get "SelectVC" segue instruction
                    myTableView.reloadData()
                    
                }
                // reset cell center to center of screen
                self.center.x = self.bounds.width/2
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 5
        reqImage.layer.masksToBounds = true
        reqImage.layer.cornerRadius = 30
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            self.messageTitle.textColor = UIColor.black
            swipeIcon.isHidden = false
            connectLabel.isHidden = false
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
            self.messageTitle.textColor = UIColor.white
            swipeIcon.isHidden = true
            connectLabel.isHidden = true
            
        }
    }

}
