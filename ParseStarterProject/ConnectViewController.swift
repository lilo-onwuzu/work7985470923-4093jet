//
//  ConnectViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//


import UIKit

class ConnectViewController: UIViewController {
    
    @IBOutlet weak var logo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
    }

    @IBAction func posted(_ sender: UIButton) {
        performSegue(withIdentifier: "toPostedTable", sender: self)
        
    }
    
    @IBAction func accepted(_ sender: UIButton) {
        performSegue(withIdentifier: "toAcceptedTable", sender: self)
        
    }
    
    @IBAction func backToProfile(_ sender: AnyObject) {
        performSegue(withIdentifier: "backToProfile", sender: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
