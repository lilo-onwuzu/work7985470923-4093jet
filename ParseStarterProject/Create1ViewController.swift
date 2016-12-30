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
    // new createJob object is initialized with vc
    var createJob: PFObject = PFObject(className: "Job")

    @IBOutlet weak var jobTitle: UITextField!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var menuView: UIView!

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
        menuView.isHidden = true
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
    
    override func viewDidLayoutSubviews() {
        if UIDevice.current.orientation.isLandscape {
            // hide createJob Icon when in landscape
            for view in self.view.subviews {
                if view.tag == 1 {
                    view.isHidden = true
                    
                }
            }
        } else {
            // else show createJob Icon in portrait
            for view in self.view.subviews {
                if view.tag == 1 {
                    view.isHidden = false
                    
                }
            }
        }
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        // place home view in menuView
        menuView = vc.view
        let view = menuView.subviews[1]
        // hide logo to prevent logo repeat
        view.isHidden = true
        self.view.addSubview(menuView)
        // menuView is hidden in viewDidLoad, now it is displayed
        UIView.transition(with: menuView,
                            duration: 2,
                            options: .transitionFlipFromRight,
                            animations: { self.menuView.isHidden = false },
                            completion: nil)
        
    }
    
    @IBAction func addJobTitle(_ sender: UIButton) {
        addTitle()

    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        menuView.isHidden = true

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
