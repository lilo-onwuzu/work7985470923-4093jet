//
//  ProfileViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var displayLocation: UILabel!
    @IBOutlet weak var displayStory: UILabel!
    @IBOutlet weak var editStory: UITextField!
    
    let user = PFUser.current()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstName = user.object(forKey: "first_name") as! String
        let lastName = user.object(forKey: "last_name") as! String
        if let story = user.object(forKey: "story") {
            displayStory.text = String(describing: story)
        }

        displayName.text = firstName + " " + lastName
        
        let imageFile = user.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                self.userImage.image = UIImage(data: imageData as Data)
            } else if let error = error {
                print(error)
            }
        }
    }

    @IBAction func edit(_ sender: AnyObject) {
        let editStory = self.editStory.text!
        displayStory.text = editStory
        
        user["story"] = editStory
        user.saveInBackground(block: { (success, error) in
            if error != nil {
                print(error)
                // show Parse Save Error Alert and terminate function
            } else {
                print(success)
            }
        })
    }
    
    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
