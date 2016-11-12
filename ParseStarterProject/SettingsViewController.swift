//
//  SettingsViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

// ApplePay
// Change Password
// Change Display Pic
// Delete PFUser Account
// Update FB Login

import UIKit

class SettingsViewController: UIViewController {

    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hello")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
