//
//  SearchViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobCycle: UILabel!
    @IBOutlet weak var jobStory: UILabel!
    @IBOutlet weak var jobRate: UILabel!

    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: "Job")
//        query.limit = 1
        
        query.findObjectsInBackground { (jobs, error) in
            if let jobs = jobs {
                print(jobs)
    
                for job in jobs {
                    print(job.object(forKey: "rate")!)
                }
                
            }
        }
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
