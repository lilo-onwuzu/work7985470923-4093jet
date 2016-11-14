//
//  ProfileViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userStory: UILabel!
    @IBOutlet weak var editStory: UITextField!
    
    let user = PFUser.current()!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstName = user.object(forKey: "first_name") as! String
        let lastName = user.object(forKey: "last_name") as! String
        if let story = user.object(forKey: "story") {
            userStory.text = String(describing: story)
        }

        userName.text = firstName + " " + lastName
        
        let imageFile = user.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                self.userImage.image = UIImage(data: imageData as Data)
            } else if let error = error {
                print(error)
            }
        }
        userStory.layer.masksToBounds = true
        userStory.layer.cornerRadius = 10.0
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3.0
        
    }

    @IBAction func edit(_ sender: AnyObject) {
        let editStory = self.editStory.text!
        userStory.text = editStory
        
        user["story"] = editStory
        user.saveInBackground(block: { (success, error) in
            if let error = error?.localizedDescription {
                self.errorAlert(title: "Database Error", message: error)
                
            } else {

            }
        })
    }
    
    @IBAction func message(_ sender: AnyObject) {
        performSegue(withIdentifier: "toConnect", sender: self)
        
    }
    
    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
