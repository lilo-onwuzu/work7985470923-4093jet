//
//  SearchViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// rethink this view
// geopoint issue. sometime gets (0,0). restart computer solves issue

import UIKit

class SearchViewController: UIViewController {

	var showMenu = false
	var viewedJobId = String()
	var keepId = String()
	let user = PFUser.current()!
	var currentJob = PFObject(className: "Job")
	
	@IBOutlet weak var requesterName: UILabel!
	@IBOutlet weak var jobTitle: UILabel!
	@IBOutlet weak var jobCycle: UILabel!
	@IBOutlet weak var jobRate: UILabel!
	@IBOutlet weak var jobLocation: UILabel!
	@IBOutlet weak var jobDetails: UITextView!
	@IBOutlet weak var logo: UILabel!
	@IBOutlet weak var wheelbarrow: UIImageView!
	@IBOutlet weak var viewProfile: UIButton!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var menuView: UIView!
	@IBOutlet weak var menuIcon: UIButton!
	
	func errorAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
			
		}))
		present(alert, animated: true, completion: nil)
		
	}
	
	func drag(gesture: UIPanGestureRecognizer) {
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
				// add user id to array of users who accepted/swiped right for this job
				currentJob.addUniqueObject(user.objectId!, forKey: "userAccepted")
				currentJob.saveInBackground()
				
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
						self.currentJob = job
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
						self.keepId = requesterId
						do {
							let user = try PFQuery.getUserObject(withId: requesterId)
							let firstName = user.object(forKey: "first_name") as? String
							let lastName = user.object(forKey: "last_name") as? String
							self.requesterName.text = "Requester: " + firstName! + " " + lastName!
							
							// enable viewProfile and infoLabel
							self.viewProfile.isHidden = false
							self.infoLabel.isHidden = false

						} catch _ {
							
						}
					}
				} else {
					self.errorAlert(title: "There are no more jobs around your area", message: "Please check again later")
					
				}
			}
			self.jobDetails.sizeToFit()
			
		}
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		// attach gestureRecognizer/listener to swiping element once view loads
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
		wheelbarrow.addGestureRecognizer(pan)
		wheelbarrow.isUserInteractionEnabled = true
		logo.layer.masksToBounds = true
		logo.layer.cornerRadius = 3
		requesterName.layer.masksToBounds = true
		requesterName.layer.cornerRadius = 3
		viewProfile.layer.cornerRadius = 10
		// disable viewProfile and infoLabel
		viewProfile.isHidden = true
		self.infoLabel.isHidden = true
		// query first job once view loads
		getNewJob()
		menuView.isHidden = true
		
	}
	
	@IBAction func mainMenu(_ sender: Any) {
		if showMenu == false {
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
			menuView = vc.view
			let view = menuView.subviews[1]
			view.isHidden = true
			menuView.frame = CGRect(x: 0, y: 69, width: (0.8 * self.view.bounds.width), height: (self.view.bounds.height - 15))
			menuView.alpha = 0
			self.view.addSubview(menuView)
			UIView.transition(with: menuView,
			                  duration: 0.25,
			                  options: .curveEaseInOut,
			                  animations: { self.menuView.alpha = 1 },
			                  completion: nil)
			menuView.isHidden = false
			showMenu = true
			
		} else if showMenu == true {
			let view = self.view.subviews.last!
			view.removeFromSuperview()
			showMenu = false

		}
	}
	
	@IBAction func toRequester(_ sender: Any) {
		performSegue(withIdentifier: "toReqProfile", sender: self)
	
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toReqProfile" {
			let vc = segue.destination as! UserProfileViewController
			vc.reqId = self.keepId
				
		}
	}
	
}
