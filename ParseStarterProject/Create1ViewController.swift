//
//  CreateViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

var createJob: PFObject = PFObject(className: "Job")

class CreateViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var jobTitle: UITextField!
    @IBOutlet weak var logo: UILabel!
    
    var finish: Bool = false
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func addTitle() {
        // first add job location (latitude & longitude) with PFGeoPoint
        // async call, use block
        PFGeoPoint.geoPointForCurrentLocation { (location, error) in
            if let location = location {
                createJob.add(location, forKey: "location")
                // start adding job info after location is gotten
                if self.jobTitle.text != "" || self.jobTitle.text != "Describe your job in 1-3 words" {
                    // PFUser.current() must exist here because the login screen comes before this
                    let user = PFUser.current()!
                    let userId = (user.objectId)!
                    let facebookId = (user.object(forKey: "facebookId"))!
                    
                    // add attributes to createJob PFObject first
                    createJob.add(self.jobTitle.text!, forKey: "title")
                    createJob.add(userId, forKey: "requesterId")
                    createJob.add(facebookId, forKey: "requesterFid")
                    self.finish = true
                    
                } else {
                    self.errorAlert(title: "Invalid Entry", message: "Please add a job title")
                    
                }
            } else {
                    self.errorAlert(title: "Error Getting Location", message: error!.localizedDescription)
                    
            }
        }
        // wait till finish is true before segue
        if finish {
            performSegue(withIdentifier: "toCreate2", sender: self)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // allows view controller to control the keyboard using a text field delegate
        self.jobTitle.delegate = self
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
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
