//
//  SettingsViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// connect apple pay 

import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let user = PFUser.current()!

    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var changedPassword: UILabel!
    @IBOutlet weak var deletedAccount: UILabel!
    @IBOutlet weak var deleteAccount: UIButton!
    @IBOutlet weak var connectedPay: UILabel!

    func deleteUser() {
        user.deleteInBackground { (success, error) in
            if success {
                self.deletedAccount.text = "Your account has been deleted. Thanks for using WorkJet"
                
            } else {
                if let error = error {
                    self.errorAlert(title: "Account Delete Error", message: error.localizedDescription)
                    
                }
            }
        }
    }
    
    func change() {
        user.password = password.text
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        deleteAccount.layer.cornerRadius = 5
        changePassword.layer.cornerRadius = 5
        
    }
    
    @IBAction func changePassword(_ sender: Any) {
        if password.text != "" {
            confirmAlert(title: "Confirm Password Change", message: "Are you sure you want to change your password?", selector: #selector(change))
            
        } else {
            errorAlert(title: "Invalid Password", message: "Please enter a valid password")
            
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        confirmAlert(title: "Confirm Delete Account", message: "Are you sure you want to delete your account?", selector: #selector(deleteUser))
  
    }
    
    @IBAction func home(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
