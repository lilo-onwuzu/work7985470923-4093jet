//
//  SearchViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SearchViewController: UIViewController {

	var viewedJobId = String()
	var keepId = String()
	let user = PFUser.current()!
	var currentJob = PFObject(className: "Job")
	
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
	@IBOutlet weak var reqImage: UIImageView!
	@IBOutlet weak var titleIcon: UIButton!
	@IBOutlet weak var cycleIcon: UIButton!
	@IBOutlet weak var rateIcon: UIButton!
	@IBOutlet weak var detailsIcon: UIButton!
	@IBOutlet weak var locationIcon: UIButton!
	
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
							//let firstName = user.object(forKey: "first_name") as? String
							//let lastName = user.object(forKey: "last_name") as? String
							//self.requesterName.text = "Requester: " + firstName! + " " + lastName!
							let imageFile = user.object(forKey: "image") as! PFFile
							imageFile.getDataInBackground { (data, error) in
								if let data = data {
									let imageData = NSData(data: data)
									self.reqImage.image = UIImage(data: imageData as Data)
									
								}
							}
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
		wheelbarrow.isUserInteractionEnabled = true
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
		wheelbarrow.addGestureRecognizer(pan)
		logo.layer.masksToBounds = true
		logo.layer.cornerRadius = 3
		viewProfile.layer.cornerRadius = 50
		// disable viewProfile and infoLabel
		viewProfile.isHidden = true
		self.infoLabel.isHidden = true
		// query first job once view loads
		reqImage.layer.masksToBounds = true
		reqImage.layer.cornerRadius = 50
		jobTitle.layer.masksToBounds = true
		jobTitle.layer.cornerRadius = 50
		jobCycle.layer.masksToBounds = true
		jobCycle.layer.cornerRadius = 50
		jobRate.layer.masksToBounds = true
		jobRate.layer.cornerRadius = 50
		jobDetails.layer.masksToBounds = true
		jobDetails.layer.cornerRadius = 20
		jobLocation.layer.masksToBounds = true
		jobLocation.layer.cornerRadius = 20
		getNewJob()
		menuView.isHidden = true
		self.reqImage.alpha = 0
		self.viewProfile.alpha = 0
		self.jobTitle.alpha = 0
		self.titleIcon.alpha = 0
		self.jobCycle.alpha = 0
		self.cycleIcon.alpha = 0
		self.jobRate.alpha = 0
		self.rateIcon.alpha = 0
		self.jobDetails.alpha = 0
		self.detailsIcon.alpha = 0
		self.jobLocation.alpha = 0
		self.locationIcon.alpha = 0

	}
	
	override func viewDidAppear(_ animated: Bool) {
		UIView.animate(withDuration: 0,
		               delay: 0,
		               usingSpringWithDamping: 60,
		               initialSpringVelocity: 0.0,
		               options: [],
		               animations: {
						self.reqImage.center.x -= 70
						self.viewProfile.center.x -= 70
						self.jobTitle.center.x += 70
						self.titleIcon.center.x += 70
						self.jobCycle.center.x -= 70
						self.cycleIcon.center.x -= 70
						self.jobRate.center.x += 70
						self.rateIcon.center.x += 70
						self.jobDetails.center.y += 30
						self.detailsIcon.center.y += 30
						self.jobLocation.center.y += 30
						self.locationIcon.center.y += 30
		}, completion: nil)
		UIView.animate(withDuration: 2,
		               delay: 0,
		               usingSpringWithDamping: 60,
		               initialSpringVelocity: 0.0,
		               options: .transitionCrossDissolve,
		               animations: {
						self.reqImage.alpha = 1
						self.reqImage.center.x += 70
						self.viewProfile.alpha = 1
						self.viewProfile.center.x += 70
						self.jobTitle.alpha = 1
						self.jobTitle.center.x -= 70
						self.titleIcon.alpha = 1
						self.titleIcon.center.x -= 70
						self.jobCycle.alpha = 1
						self.jobCycle.center.x += 70
						self.cycleIcon.alpha = 1
						self.cycleIcon.center.x += 70
						self.jobRate.alpha = 1
						self.jobRate.center.x -= 70
						self.rateIcon.alpha = 1
						self.rateIcon.center.x -= 70
						self.jobDetails.alpha = 1
						self.jobDetails.center.y -= 30
						self.detailsIcon.alpha = 1
						self.detailsIcon.center.y -= 30
						self.jobLocation.alpha = 1
						self.jobLocation.center.y -= 30
						self.locationIcon.alpha = 1
						self.locationIcon.center.y -= 30
		}, completion: nil)
	
	}
	
	override func viewDidLayoutSubviews() {
		if UIDevice.current.orientation.isLandscape {
			// reform view when in landscape
			UIView.animate(withDuration: 0,
			               delay: 0,
			               usingSpringWithDamping: 60,
			               initialSpringVelocity: 0.0,
			               options: [],
			               animations: {
							self.jobTitle.center.y += 75
							self.titleIcon.center.y += 75
							self.viewProfile.center.y += 75
							self.reqImage.center.y += 75
							self.jobCycle.center.x -= 170
							self.cycleIcon.center.x -= 170
							self.jobRate.center.x += 170
							self.rateIcon.center.x += 170
							
			}, completion: nil)
		}
	}
	
	@IBAction func mainMenu(_ sender: Any) {
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
		// place home view in menuView
		menuView = vc.view
		let view = menuView.subviews[1]
		// hide logo to prevent logo repeat
		view.isHidden = true
		self.view.addSubview(menuView)
		// menuView is hidden in viewDidLoad, now it is displayed
		UIView.transition(with: menuView,
		                  duration: 2,
		                  options: .transitionFlipFromRight,
		                  animations: { self.menuView.isHidden = false },
		                  completion: nil)
		
	}
	
	@IBAction func toRequester(_ sender: Any) {
		performSegue(withIdentifier: "toReqProfile", sender: self)

	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toReqProfile" {
			let vc = segue.destination as! UserProfileViewController
			vc.reqId = self.keepId
				
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		menuView.isHidden = true
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
