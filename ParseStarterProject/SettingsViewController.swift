//
//  SettingsViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

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
                                        object.deleteInBackground(block: { (success, error) in
                                            if success {
                                                self.user.deleteInBackground { (success, error) in
                                                    if success {
                                                        self.performSegue(withIdentifier: "toHome", sender: self)
                                                        
                                                    }
                                                }
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
    
    @IBAction func openMenu(_ sender: Any) {
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
