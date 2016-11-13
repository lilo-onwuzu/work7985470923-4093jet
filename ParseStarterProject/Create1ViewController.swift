//
//  CreateViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// location add unsuccessful
// save job only at end 

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
    
    func addTitle() {
        if jobTitle.text != "" || jobTitle.text != "Describe your job in 1-3 words" {
            // PFUser.current() must exist here because the login screen comes before this
            let user = PFUser.current()!
            let userId = (user.objectId)!
            let facebookId = (user.object(forKey: "facebookId"))!
            
            // add attributes to PFObject first
            let job = PFObject(className: "Job")
            job.add(jobTitle.text!, forKey: "title")
            job.add(userId, forKey: "requesterId")
            job.add(facebookId, forKey: "requesterFid")
            // add job location (latitude & longitude) with PFGeoPoint
            PFGeoPoint.geoPointForCurrentLocation(inBackground: { (geoPoint, error) in
                let point = geoPoint!
                job.add(point, forKey: "location")

//                if let geoPoint = geoPoint {
//                    print(geoPoint)
//                    job.add(geoPoint, forKey: "location")
//                    
//                }
            })
            
            // now save PFObject to Parse
            // saveInBackground is an asychronous call that does not wait to execute before continuing so save it with block if you need data that is returned from the async call
            job.saveInBackground(block: { (success, error) in
                if error != nil {
                    self.errorAlert(title: "Database Error", message: "Please try again later")
                    
                } else {
                    jobId = job.objectId!
                    self.performSegue(withIdentifier: "toCreate2", sender: self)
                    
                }
            })
        } else {
            errorAlert(title: "Invalid Entry", message: "Please add a job title")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // allows view controller to control the keyboard using a text field delegate
        self.jobTitle.delegate = self

    }
    
    @IBAction func addJobTitle(_ sender: UIButton) {
        addTitle()
        
    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addTitle()
        return true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}
