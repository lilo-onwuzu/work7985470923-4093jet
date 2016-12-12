//
//  SettingsViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let user = PFUser.current()!
    var showMenu = false
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var changedPassword: UILabel!
    @IBOutlet weak var deletedAccount: UILabel!
    @IBOutlet weak var deleteAccount: UIButton!
    @IBOutlet weak var connectedPay: UILabel!
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
    
    func savePassword() {
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
        
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        if showMenu == false {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            menuView = vc.view
            let view = menuView.subviews[1]
            view.isHidden = true
            menuView.frame = CGRect(x: 0, y: 69, width: (0.8 * self.view.bounds.width), height: (self.view.bounds.height - 15))
            menuView.alpha = 0
            self.view.addSubview(menuView)
            UIView.transition(with: menuView,
                              duration: 0.25,
                              options: .curveEaseInOut,
                              animations: { self.menuView.alpha = 1 },
                              completion: nil)
            menuView.isHidden = false
            showMenu = true
            
        } else if showMenu == true {
            let view = self.view.subviews.last!
            view.removeFromSuperview()
            showMenu = false
            
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        changeAction()
        
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        confirmAlert(title: "Confirm Delete Account", message: "Are you sure you want to delete your account?", selector: #selector(deleteUser))
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
