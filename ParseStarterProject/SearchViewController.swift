//
//  SearchViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

// swipe features
// add touchbar 

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobCycle: UILabel!
    @IBOutlet weak var jobStory: UILabel!
    @IBOutlet weak var jobRate: UILabel!
	@IBOutlet weak var requesterImage: UIImageView!

    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }
	
	func drag(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self.view)
		print(translation)
		
		if gesture.state == UIGestureRecognizerState.ended {
			print(jobStory.center.x)
//			print(jobStory.center.y)
		}
		
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
		jobStory.addGestureRecognizer(pan)
		jobStory.isUserInteractionEnabled = true
		
        let query = PFQuery(className: "Job")
        query.limit = 1
        query.findObjectsInBackground {(jobs, error) in
            if let jobs = jobs {
                for job in jobs {
                    let title = job.object(forKey: "title") as! NSArray
                    let jobTitle = title[0] as! String
                    self.jobTitle.text = jobTitle
                    let rate = job.object(forKey: "rate") as! NSArray
                    let jobRate = rate[0] as! String
                    self.jobRate.text = "$" + jobRate
                    let cycle = job.object(forKey: "cycle") as! NSArray
                    let jobCycle = cycle[0] as! String
                    self.jobCycle.text = jobCycle
                    let details = job.object(forKey: "details") as! NSArray
                    let jobDetails = details[0] as! String
                    self.jobStory.text = jobDetails

                    // get requester info
                    let userId = job.object(forKey: "requesterId") as! NSArray
                    let requesterId = userId[0] as! String
					
					do {
						let user = try PFQuery.getUserObject(withId: requesterId)
						let firstName = user.object(forKey: "first_name") as? String
						let lastName = user.object(forKey: "last_name") as? String
						self.requesterName.text = firstName! + " " + lastName!
						let imageFile = user.object(forKey: "image") as! PFFile
						imageFile.getDataInBackground { (data, error) in
							if let data = data {
								let imageData = NSData(data: data)
								self.requesterImage.image = UIImage(data: imageData as Data)
							}
						}
					} catch _ {
						
					}
					
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
