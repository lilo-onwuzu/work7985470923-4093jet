//
//  PostedTableViewCell.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
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
        
//        let pan = UIGestureRecognizer(target: self, action: Selector("drag"))
//        self.addGestureRecognizer(pan)
//        self.isUserInteractionEnabled = true
//        if self.isSelected {
//            print("check")
//        }
        
    }

//    func drag(gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self)
//        // cell moves with pan gesture
//        self.center.x = self.center.x + translation.x
//        
//        if gesture.state == UIGestureRecognizerState.ended {
//            // positive x pan
//            if translation.x > 0 {
//                print("message view")
//                
//            // negative x pan
//            } else if translation.x < 0 {
//                print("crud view")
//                
//            }
//            
//        }
//        
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }

}
