//
//  ViewController.swift
//  
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUp", sender: self)
        
    }
    
    @IBAction func login(_ sender: AnyObject) {
        performSegue(withIdentifier: "toLogin", sender: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

