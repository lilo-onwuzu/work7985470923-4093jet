//
//  CreateViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

// ISSUES: print actual error
// job title saves placeholder if not edited

import UIKit

var jobId: String = ""

class CreateViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var jobTitle: UITextField!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allows view controller to control the keyboard using a text field delegate
        self.jobTitle.delegate = self
        
    }
    
    @IBAction func addJobTitle(_ sender: UIButton) {
    
        if jobTitle.text != "" {
            let user = PFUser.current()
            let userId = (user?.objectId)!
            let facebookId = (user?.object(forKey: "facebookId"))!
            
            // save to Parse as PFObject attribute
            let job = PFObject(className: "Job")
            job.add(jobTitle.text!, forKey: "title")
            job.add(userId, forKey: "requesterId")
            job.add(facebookId, forKey: "requesterFid")

            // saveInBackground is an asychronous call that does not wait to execute before continuing so save it with block if you need data that is returned from the async call
            job.saveInBackground(block: { (success, error) in
                if error != nil {
                    self.errorAlert(title: "Parse Save Error", message: "Please try again later")
                
                } else {
                    jobId = job.objectId!
                    
                }
            })
            
            self.performSegue(withIdentifier: "toCreate2", sender: self)

            
        } else {
            errorAlert(title: "Invalid Form Entry", message: "Please add a job title")
        
        }
    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true

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
