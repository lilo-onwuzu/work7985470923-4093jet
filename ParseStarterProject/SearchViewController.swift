//
//  SearchViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//


import UIKit

class SearchViewController: UIViewController {

	var viewedJobId = ""

    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobCycle: UILabel!
    @IBOutlet weak var jobStory: UILabel!
    @IBOutlet weak var jobRate: UILabel!
	@IBOutlet weak var requesterImage: UIImageView!
    @IBOutlet weak var wheelbarrow: UIImageView!
	
	func drag(_ gesture: UIPanGestureRecognizer) {
		// translation measures the distance of a pan. It can be positive or negative
		let translation = gesture.translation(in: self.view)
		// allows wheelbarrow center to move in x with pan. wheelbarrow.center.x decreases in x or moves left when pan is to the left
		wheelbarrow.center.x = self.view.center.x + translation.x
		// xFromCenter is +ve if pan is to the right and -ve is pan is to the left
		let xFromCenter = wheelbarrow.center.x - self.view.bounds.width / 2
		var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
		let scale = min(100 / abs(xFromCenter), 1)
		var stretch = rotation.scaledBy(x: scale, y: scale)
		wheelbarrow.transform = stretch
		
		// once panning ends, record swipe left or right action, filter viewed job from showing up later, reset swipe element to initial position then finally fetch a new job from database
		if gesture.state == UIGestureRecognizerState.ended {
			var acceptedOrRejected = ""
			if xFromCenter > 100 {
				acceptedOrRejected = "accepted"
				
			} else if xFromCenter < -100 {
				acceptedOrRejected = "rejected"
				
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
	
    func getNewJob() {
		let query = PFQuery(className: "Job")
		query.limit = 1
		
		// query with PFUser's location
		let location = PFUser.current()?["location"] as? PFGeoPoint
		if let latitude = location?.latitude {
			if let longitude = location?.longitude {
				query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast:PFGeoPoint(latitude:latitude + 1, longitude: longitude + 1))

			}
		}
		
		// query with already viewed jobs
		var ignoredJobs = [String]()
		if let acceptedJobs = PFUser.current()?["accepted"] {
			ignoredJobs += acceptedJobs as! Array
			
		}
		if let rejectedJobs = PFUser.current()?["rejected"] {
			ignoredJobs += rejectedJobs as! Array
			
		}
		query.whereKey("objectId", notContainedIn: ignoredJobs)
		
		// perform query (get job details and job requester's details)
		query.findObjectsInBackground { (jobs, error) in
			if let jobs = jobs {
				for job in jobs {
					
					// get job details
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
					
					// get job requester name and photo
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
		// attach gestureRecognizer/listener to swiping element once view loads
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
		wheelbarrow.addGestureRecognizer(pan)
		wheelbarrow.isUserInteractionEnabled = true
		
		// query first job once view loads
		getNewJob()
		
	}
	
	@IBAction func home(_ sender: AnyObject) {
		performSegue(withIdentifier: "backHome", sender: self)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
