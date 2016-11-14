//
//  HomeViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    
    @IBAction func profile(_ sender: AnyObject) {
        performSegue(withIdentifier: "toProfile", sender: self)
    
    }
    
    @IBAction func search(_ sender: AnyObject) {
        performSegue(withIdentifier: "toSearch", sender: self)
    
    }
    
    @IBAction func create(_ sender: AnyObject) {
        performSegue(withIdentifier: "toCreate", sender: self)
    
    }
    
    @IBAction func settings(_ sender: AnyObject) {
        performSegue(withIdentifier: "toSettings", sender: self)
    
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        let empty = [""]
        PFUser.current()!["accepted"] = empty
        PFUser.current()!["rejected"] = empty
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if success {
                PFUser.logOut()
                self.performSegue(withIdentifier: "toMain", sender: self)

            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
