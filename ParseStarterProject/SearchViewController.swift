//
//  SearchViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SearchViewController: UIViewController {

	var viewedJobId = String()

	@IBOutlet weak var requesterName: UILabel!
	@IBOutlet weak var jobTitle: UILabel!
	@IBOutlet weak var jobCycle: UILabel!
	@IBOutlet weak var jobRate: UILabel!
	@IBOutlet weak var jobLocation: UILabel!
	@IBOutlet weak var jobDetails: UILabel!
	@IBOutlet weak var logo: UILabel!
	@IBOutlet weak var wheelbarrow: UIImageView!
	@IBOutlet weak var viewProfile: UIButton!
	
	func errorAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
			
		}))
		present(alert, animated: true, completion: nil)
		
	}
	
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
		let location = PFUser.current()?["job_location"] as? PFGeoPoint
		if let latitude = location?.latitude{
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
				if jobs.count > 0 {
					for job in jobs {
						// get job details
						self.viewedJobId = job.objectId!
						let jobTitle = job.object(forKey: "title") as! String
						self.jobTitle.text = jobTitle
						let jobRate = job.object(forKey: "rate") as! String
						self.jobRate.text = "$" + jobRate
						let jobCycle = job.object(forKey: "cycle") as! String
						self.jobCycle.text = jobCycle
						let jobDetails = job.object(forKey: "details") as! String
						self.jobDetails.text = jobDetails
						
						// get job requester name and photo
						let requesterId = job.object(forKey: "requesterId") as! String
						do {
							let user = try PFQuery.getUserObject(withId: requesterId)
							let firstName = user.object(forKey: "first_name") as? String
							let lastName = user.object(forKey: "last_name") as? String
							self.requesterName.text = "Requester: " + firstName! + " " + lastName!

						} catch _ {
							
						}
					}
				} else {
					self.errorAlert(title: "There are no more jobs around your area", message: "Please check again later")
					
				}
			}
		}
		jobDetails.sizeToFit()
		
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		// attach gestureRecognizer/listener to swiping element once view loads
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
		wheelbarrow.addGestureRecognizer(pan)
		wheelbarrow.isUserInteractionEnabled = true
		logo.layer.masksToBounds = true
		logo.layer.cornerRadius = 3
		requesterName.layer.masksToBounds = true
		requesterName.layer.cornerRadius = 3
		viewProfile.layer.cornerRadius = 10
		
		// query first job once view loads
		getNewJob()
		
	}
	
	@IBAction func home(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
