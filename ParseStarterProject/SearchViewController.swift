//
//  SearchViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

// location aware

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobCycle: UILabel!
    @IBOutlet weak var jobStory: UILabel!
    @IBOutlet weak var jobRate: UILabel!
	@IBOutlet weak var requesterImage: UIImageView!
    @IBOutlet weak var wheelbarrow: UIImageView!
	
	var viewedJobId = ""

    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }
	
    func getNewJob() {
		let query = PFQuery(className: "Job")
		query.limit = 1
		var ignoredJobs = [""]
		if let acceptedJobs = PFUser.current()?["accepted"] {
			ignoredJobs += acceptedJobs as! Array
		}
		if let rejectedJobs = PFUser.current()?["rejected"] {
			ignoredJobs += rejectedJobs as! Array
		}
		query.whereKey("objectId", notContainedIn: ignoredJobs)
    
//		query.whereKey("location", withinGeoBoxFromSouthwest:PFGeoPoint(latitude:0, longitude:0), toNortheast:PFGeoPoint(latitude:5, longitude:5))
		
		query.findObjectsInBackground { (jobs, error) in
			if let jobs = jobs {
				for job in jobs {
					self.viewedJobId = job.objectId!
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
	
	func drag(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self.view)
        wheelbarrow.center.x = self.view.center.x + translation.x
        
        let xFromCenter = wheelbarrow.center.x - self.view.bounds.width / 2
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        let scale = min(100 / abs(xFromCenter), 1)
        var stretch = rotation.scaledBy(x: scale, y: scale)
        wheelbarrow.transform = stretch
        
		if gesture.state == UIGestureRecognizerState.ended {
			var acceptedOrRejected = ""

			if wheelbarrow.center.x > 100 {
				acceptedOrRejected = "rejected"
				
            } else if wheelbarrow.center.x < self.view.bounds.width - 100 {
				acceptedOrRejected = "accepted"
				
            }
			if acceptedOrRejected != "" {
				PFUser.current()?.addUniqueObjects(from: [viewedJobId], forKey:acceptedOrRejected)
				PFUser.current()?.saveInBackground()
				
			}
			
            wheelbarrow.center.x = self.view.center.x
            rotation = CGAffineTransform(rotationAngle: 0)
            stretch = rotation.scaledBy(x: 1, y: 1)
            wheelbarrow.transform = stretch
            getNewJob()
			
		}
	}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
		wheelbarrow.addGestureRecognizer(pan)
		wheelbarrow.isUserInteractionEnabled = true
		
		getNewJob()
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
