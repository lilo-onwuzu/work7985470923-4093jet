//
//  UserProfileViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


// resize details textfield to fit

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
        // get requester details and image
        do {
            let user = try PFQuery.getUserObject(withId: reqId)
            let firstName = user.object(forKey: "first_name") as! String
            let lastName = user.object(forKey: "last_name") as! String
            userName.text = firstName + " " + lastName
            let story = user.object(forKey: "story") as! String
            details.text = story
            details.sizeToFit()
            // get requester image
            let imageFile = user.object(forKey: "image") as! PFFile
            imageFile.getDataInBackground { (data, error) in
                if let data = data {
                    let imageData = NSData(data: data)
                    self.userImage.image = UIImage(data: imageData as Data)
                    self.scrollView.sizeToFit()
                    
                } else {
                    
                }
            }
            scrollView.sizeToFit()
            
        } catch _ {
            
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
