//
//  ReceivedTableViewCell.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ReceivedTableViewCell: UITableViewCell {

    var ready = false
    var myTableView = UITableView()
    var selectedRow = Int()
    
    @IBOutlet weak var receivedTitle: UILabel!
    @IBOutlet weak var receivedRate: UILabel!
    @IBOutlet weak var receivedCycle: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var matchIcon: UIButton!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var imageFrame: UIButton!
    
    func recenterIcon () {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .transitionCrossDissolve,
                       animations: { self.matchIcon.center.y += 20 },
                       completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        receivedLabel.layer.masksToBounds = true
        receivedLabel.layer.cornerRadius = 7
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 45
        imageFrame.layer.masksToBounds = true
        imageFrame.layer.cornerRadius = 45
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the highlighted color for the selected state
        if selected {
            self.receivedTitle.textColor = UIColor.black
            matchIcon.isHidden = false
            matchLabel.isHidden = false
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.0,
                           options: .transitionCrossDissolve,
                           animations: { self.matchIcon.center.y -= 20 },
                           completion: { (success) in
                            self.recenterIcon()
                            
            })
        } else {
            self.receivedTitle.textColor = UIColor.white
            matchIcon.isHidden = true
            matchLabel.isHidden = true
            
        }
    }
    
    @IBAction func viewProfile(_ sender: Any) {
        self.ready = true
        if let row = myTableView.indexPathForSelectedRow?.row {
            self.selectedRow = row
            
        }
        myTableView.reloadData()
    
    }
    
}
