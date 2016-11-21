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
    var confirm = false

    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var changedPassword: UILabel!
    @IBOutlet weak var deletedAccount: UILabel!
    @IBOutlet weak var deleteAccount: UIButton!
    @IBOutlet weak var connectedPay: UILabel!

    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No I'll Stay", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            // set confirm to true to run PFUser delete
            self.confirm = true
            
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
            user.password = password.text
            user.saveInBackground { (success, error) in
                if success {
                    self.changedPassword.text = "Your password has been updated!"
                    
                } else {
                    if let error = error {
                        self.errorAlert(title: "Update Password Error", message: error.localizedDescription)
                        
                    }
                }
            }
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        deleteAlert(title: "Confirm Delete Account", message: "Are you sure you want to delete your account?")
        if confirm {
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
    }
    
    @IBAction func home(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
