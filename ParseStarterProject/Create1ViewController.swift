//
//  CreateViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var jobTitle: UITextField!
    @IBOutlet weak var logo: UILabel!
    
    var finish: Bool = false
    
    // new createJob object is initialized with VC
    var createJob: PFObject = PFObject(className: "Job")
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func addTitle() {
        // wait till location is obtained and saved before adding job details
        if finish {
            // add job info
            if self.jobTitle.text != "" || self.jobTitle.text != "Describe your job in 1-3 words" {
                // PFUser.current() must exist here because the login screen comes before this
                let user = PFUser.current()!
                let userId = (user.objectId)!
                let facebookId = (user.object(forKey: "facebookId"))!
                
                // add attributes to createJob PFObject first
                // .setValue() sets value of a type while .add() create an array type column and adds to it
                createJob.setValue(self.jobTitle.text!, forKey: "title")
                createJob.setValue(userId, forKey: "requesterId")
                createJob.setValue(facebookId, forKey: "requesterFid")
                performSegue(withIdentifier: "toCreate2", sender: self)
                
            } else {
                self.errorAlert(title: "Invalid Entry", message: "Please add a job title")
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // allows view controller to control the keyboard using a text field delegate
        self.jobTitle.delegate = self
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
        // add job location (latitude & longitude) with PFGeoPoint
        // async call, use block and handshake boolean "finish"
        PFGeoPoint.geoPointForCurrentLocation { (coordinates, error) in
            if let coordinates = coordinates {
                self.createJob.setValue(coordinates, forKey: "location")
                self.finish = true
                
            } else {
                self.errorAlert(title: "Error Getting Location", message: error!.localizedDescription)
                
            }
        }
    }
    
    @IBAction func addJobTitle(_ sender: UIButton) {
        addTitle()
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreate2" {
            let nextVC = segue.destination as! Create2ViewController
            nextVC.createJob = self.createJob
            
        }
    }
    
}
