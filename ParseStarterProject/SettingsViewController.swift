//
//  SettingsViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    var showMenu = true
    let user = PFUser.current()!
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var changedPassword: UILabel!
    @IBOutlet weak var deletedAccount: UILabel!
    @IBOutlet weak var deleteAccount: UIButton!
    @IBOutlet weak var menuView: UIView!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func confirmAlert(title: String, message: String, selector: Selector ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)

            self.perform(selector)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteUser() {
        // first delete all user's posted jobs
        let userId = user.objectId!
        let queryPostedJobs = PFQuery(className: "Job")
        queryPostedJobs.whereKey("requesterId", equalTo: userId)
        queryPostedJobs.findObjectsInBackground { (objects, error) in
            if let objects = objects {
                for object in objects {
                    object.deleteInBackground(block: { (success, error) in
                        if success {
                            // then delete user as selectedUser for all jobs
                            let queryReceivedJobs = PFQuery(className: "Job")
                            queryReceivedJobs.whereKey("selectedUser", equalTo: userId)
                            queryReceivedJobs.findObjectsInBackground { (objects, error) in
                                if let objects = objects {
                                    for object in objects {
                                        object.setValue("", forKey: "selectedUser")
                                        object.saveInBackground(block: { (success, error) in
                                            if success {
                                                self.performSegue(withIdentifier: "toHome", sender: self)
                                                
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func savePassword() {
        user.password = self.password.text!
        user.saveInBackground { (success, error) in
            if success {
                self.changedPassword.text = "Your password has been updated!"
                
            } else {
                if let error = error {
                    self.errorAlert(title: "Update Password Error", message: error.localizedDescription)
                    
                }
            }
            // reset password field
            self.password.text = ""
            
        }
    }
    
    func changeAction() {
        let getPassword = self.password.text!
        let confirmPassword = self.confirmPassword.text!
        // password character length must be greater than 5
        if getPassword.characters.count >= 6 {
            if getPassword == confirmPassword {
                confirmAlert(title: "Confirm Password Change", message: "Are you sure you want to change your password?", selector: #selector(savePassword))
                
            } else {
                errorAlert(title: "Invalid Password", message: "Your entered passwords must match. Please try again")
                
            }
        } else {
            errorAlert(title: "Invalid Password", message: "Your password must have at least 6 characters")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        deleteAccount.layer.cornerRadius = 5
        changePassword.layer.cornerRadius = 5
        password.attributedPlaceholder = NSAttributedString(string:"Enter Password", attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        confirmPassword.attributedPlaceholder = NSAttributedString(string:"Confirm Password", attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        menuView.isHidden = true
        self.password.delegate = self
    
    }
    
    // hide menuView on viewDidAppear so if user presses back to return to thois view, menuView is hidden
    override func viewDidAppear(_ animated: Bool) {
        menuView.isHidden = true
        showMenu = true
        
    }
    
    override func viewDidLayoutSubviews() {
        if UIDevice.current.orientation.isLandscape {
            for view in self.view.subviews {
                // viewDidLayoutSubviews() runs each time layout changes
                // resize menuView (if present in view i.e if menuView is already being displayed) whenever orientation changes. this calculates the variable "rect" based on the new bounds
                if view.tag == 2 {
                    let xOfView = self.view.bounds.width
                    let yOfView = self.view.bounds.height
                    let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
                    menuView.frame = rect
                    
                }
            }
        } else {
            for view in self.view.subviews {
                if view.tag == 2 {
                    let xOfView = self.view.bounds.width
                    let yOfView = self.view.bounds.height
                    let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
                    menuView.frame = rect
                    
                }
            }
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        if showMenu {
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

        } else {
            menuView.isHidden = true
            showMenu = true
            
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        changeAction()
        
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        confirmAlert(title: "Confirm Delete Account", message: "Are you sure you want to delete your account? Deleting your account will delete all jobs you have posted and been accepted for. This action cannot be undone", selector: #selector(deleteUser))
  
    }

    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        menuView.isHidden = true
        showMenu = true

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

}
