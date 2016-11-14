//
//  ProfileViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userStory: UILabel!
    @IBOutlet weak var editStory: UITextField!
    
    // should not crash here because login screen appears before this
    let user = PFUser.current()!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func runEdit() {
        let editStory = self.editStory.text!
        // update displayed user story
        userStory.text = editStory
        // update user story in Parse
        user["story"] = editStory
        // save
        user.saveInBackground(block: { (success, error) in
            if let error = error?.localizedDescription {
                self.errorAlert(title: "Database Error", message: error)
        
            } else {
                self.editStory.text = "Your story has been updated!"
        
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editStory.delegate = self
        let firstName = user.object(forKey: "first_name") as! String
        let lastName = user.object(forKey: "last_name") as! String
        // if story already exists for user, convert it to string (if possible- no "!") and display it
        if let story = user.object(forKey: "story") {
            userStory.text = String(describing: story)
        
        }

        // display user's name
        userName.text = firstName + " " + lastName
        
        // display user's saved image. user image data always exists in Parse
        let imageFile = user.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                self.userImage.image = UIImage(data: imageData as Data)
            
            } else {

            }
        }
        userStory.layer.masksToBounds = true
        userStory.layer.cornerRadius = 10.0
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3.0
        
    }

    // edit action executes "after editing ends"
    @IBAction func edit(_ sender: AnyObject) {
        runEdit()
        
    }

    @IBAction func toMyJobs(_ sender: UIButton) {
        performSegue(withIdentifier: "toMyJobs", sender: self)
        
    }
    
    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        runEdit()
        return true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
