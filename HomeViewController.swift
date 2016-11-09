//
//  HomeViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
