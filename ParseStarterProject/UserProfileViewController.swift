//
//  UserProfileViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class UserProfileViewController: UIViewController {

    var reqId = ""
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
        // fetch user image
        var user = PFObject(className: "User")
        let query: PFQuery = PFUser.query()!
        query.whereKey("objectId", equalTo: reqId)
        query.findObjectsInBackground { (users, error) in
            if let users = users {
                user = users[0]
                
                // get details
                let firstName = user.object(forKey: "first_name") as! String
                let lastName = user.object(forKey: "last_name") as! String
                self.userName.text = firstName + " " + lastName
                if let story = user.object(forKey: "story") {
                    self.details.text = String(describing: story)
                    
                }
                self.details.sizeToFit()
                
                // get image
                let imageFile = user.object(forKey: "image") as! PFFile
                imageFile.getDataInBackground { (data, error) in
                    if let data = data {
                        let imageData = NSData(data: data)
                        self.userImage.image = UIImage(data: imageData as Data)
                        
                    }
                }
                
            }
        }
        
        // change view for smaller screen sizes (iPad, iPhone5 & iPhone5s)
        if UIScreen.main.bounds.height <= 650 {
            self.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
