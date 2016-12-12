//
//  CreateViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate {

    let text_field_limit = 64
    var finish: Bool = false
    // new createJob object is initialized with VC
    var createJob: PFObject = PFObject(className: "Job")

    @IBOutlet weak var jobTitle: UITextField!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var label: UILabel!

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
            if jobTitle.text != "" {
                if jobTitle.text != "First, describe your job in 1-3 words" {
                    // PFUser.current() must exist here because the login screen comes before this
                    let user = PFUser.current()!
                    let userId = (user.objectId)!
                    let facebookId = (user.object(forKey: "facebookId"))!
                    
                    // add attributes to createJob PFObject first
                    // .setValue() sets value of a type while .add() create an array type column and adds to it
                    createJob.setValue(self.jobTitle.text!, forKey: "title")
                    createJob.setValue(userId, forKey: "requesterId")
                    createJob.setValue(facebookId, forKey: "requesterFid")
                    createJob.setValue([], forKey: "userAccepted")
                    createJob.setValue("", forKey: "selectedUser")
                    performSegue(withIdentifier: "toCreate2", sender: self)
                
                } else {
                    errorAlert(title: "Invalid Entry", message: "Please add a job title")
                    
                }
            } else {
                errorAlert(title: "Invalid Entry", message: "Please add a job title")
                
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
        nextButton.alpha = 0
        label.alpha = 0
        jobTitle.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.label.alpha = 1
            self.label.center.x += 0
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.jobTitle.alpha = 0.8
            self.jobTitle.center.x += 0
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.nextButton.alpha = 1.0
            self.nextButton.center.x += 0
        }, completion: nil)
        
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= text_field_limit

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass PFObject through segue without saving to Parse
        if segue.identifier == "toCreate2" {
            let nextVC = segue.destination as! Create2ViewController
            nextVC.createJob = self.createJob
            
        }
    }
    
}
