//
//  CreateViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate {

    var showMenu = true
    //text field limit for title text
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
        
        // add alert action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))

        // present
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
                    let facebookId = user.object(forKey: "facebookId") as! String
                    // add attributes to createJob PFObject first
                    // .setValue() sets value of a type while .add() create an array type column and adds to it
                    createJob.setValue(self.jobTitle.text!, forKey: "title")
                    createJob.setValue(userId, forKey: "requesterId")
                    createJob.setValue(facebookId, forKey: "requesterFid")
                    // set empty array for users who have accepted the job on job creation
                    createJob.setValue([], forKey: "userAccepted")
                    // set empty string for user who has been selected for the job on job creation
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
    
    func displayMenu() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        // place home view in menuView
        menuView = vc.view
        let view = menuView.subviews[1]
        // hide logo to prevent logo repeat
        view.isHidden = true
        self.view.addSubview(menuView)
        // size menuView
        let xOfView = self.view.bounds.width
        let yOfView = self.view.bounds.height
        let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
        menuView.frame = rect
        // menuView is hidden in viewDidLoad, now it is displayed
        self.menuView.isHidden = false
        self.showMenu = false
        
    }
    
    func removeMenu() {
        menuView.isHidden = true
        self.showMenu = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.jobTitle.delegate = self
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        menuView.isHidden = true
        
        // add job location for job (latitude & longitude) with PFGeoPoint
        // use block for async call and handshake boolean "finish" to confirm that location was gotten if not show errorAlert
        PFGeoPoint.geoPointForCurrentLocation { (coordinates, error) in
            if let coordinates = coordinates {
                self.createJob.setValue(coordinates, forKey: "location")
                self.finish = true
                
            } else {
                self.errorAlert(title: "Error Getting Location", message: error!.localizedDescription)
                
            }
        }
        
        // change view for smaller screen sizes (iPad, iPhone5 & iPhone5s)
        if UIScreen.main.bounds.height <= 650 {
            self.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
        }
        
    }
    
    // hide menuView on viewDidAppear so if user presses back to return to thois view, menuView is hidden
    override func viewDidAppear(_ animated: Bool) {
        removeMenu()
        
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        if showMenu {
            displayMenu()

        } else {
            removeMenu()
            
        }
    }
    
    @IBAction func addJobTitle(_ sender: UIButton) {
        addTitle()

    }
    
    // tap anywhere to escape keyboard, hide menu and set showMenu to true so that double tap is not needed to display menuView again
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        removeMenu()

    }
    
    // hit return to escape keyboard and add title
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addTitle()
        return true

    }
    
    // textfield delegate so characters greater than the text field limit cannot be entered
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= text_field_limit

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass PFObject in creation through segue without saving to Parse yet
        if segue.identifier == "toCreate2" {
            let nextVC = segue.destination as! Create2ViewController
            nextVC.createJob = self.createJob
            
        }
    }
    
}
