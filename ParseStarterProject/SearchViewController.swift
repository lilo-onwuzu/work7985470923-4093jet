//
//  SearchViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SearchViewController: UIViewController {

	var showMenu = true
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
	@IBOutlet weak var flagIcon: UIButton!
	
	func errorAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
			
		}))
		present(alert, animated: true, completion: nil)
		
	}

	func finallyDeleteUser() {
		var requester = PFObject(className: "User")
		let query: PFQuery = PFUser.query()!
		query.whereKey("objectId", equalTo: self.keepId)
		query.findObjectsInBackground { (users, error) in
			if let users = users {
				requester = users[0]
				requester.deleteInBackground(block: { (success, error) in
					if success {
						self.getNewJob()
						
					}
				})
			}
		}
	}
	
	func deleteAsAccepted () {
		// then delete user as selectedUser for all jobs
		let queryReceivedJobs = PFQuery(className: "Job")
		queryReceivedJobs.whereKey("userAccepted", contains: keepId)
		queryReceivedJobs.findObjectsInBackground { (objects, error) in
			if let objects = objects {
				if objects.count > 0 {
					for object in objects {
						var userAccepted = object.object(forKey: "userAccepted") as! [String]
						// remove userId from every jobs array of acceptedUsers
						for id in userAccepted {
							if id == self.keepId {
								userAccepted.remove(at: userAccepted.index(of: id)!)
								object.setValue(userAccepted, forKey: "userAccepted")
								object.saveInBackground(block: { (success, error) in
									if success {
										self.finallyDeleteUser()
										
									}
								})
							}
						}
					}
				} else {
					// go to next step even if there are no objects
					self.finallyDeleteUser()
					
				}
			}
		}
	}
	
	func deleteAsSelected () {
		// then delete user as selectedUser for all jobs
		let queryReceivedJobs = PFQuery(className: "Job")
		queryReceivedJobs.whereKey("selectedUser", equalTo: keepId)
		queryReceivedJobs.findObjectsInBackground { (objects, error) in
			if let objects = objects {
				if objects.count > 0 {
					for object in objects {
						// empty selected user
						object.setValue("", forKey: "selectedUser")
						// empty messages too since messages only initiates with handshake agreement
						// this job will no longer be listed in message vc until another match is made
						object.remove(forKey: "messages")
						object.saveInBackground(block: { (success, error) in
							if success {
								self.deleteAsAccepted()
								
							}
						})
					}
				} else {
					// go to next step even if there are no objects
					self.deleteAsAccepted()
					
				}
			}
		}
	}
	
	func deleteUser() {
		// first delete all user's posted jobs
		let queryPostedJobs = PFQuery(className: "Job")
		queryPostedJobs.whereKey("requesterId", equalTo: keepId)
		queryPostedJobs.findObjectsInBackground { (objects, error) in
			if let objects = objects {
				if objects.count > 0 {
					for object in objects {
						object.deleteInBackground(block: { (success, error) in
							if success {
								self.deleteAsSelected()
								
							}
						})
					}
				} else {
					// go to next step even if there are no objects
					self.deleteAsSelected()
					
				}
			}
		}
	}
	
    func flagAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
			var number = Int()
			// check if flagCount already exist for this job and has a value convertible to Int()
			if let flagCount = self.currentJob.object(forKey: "flagCount") as? Int {
				// if flagCount exists then flaggers array must exist in PFObject
				let ids = self.currentJob.object(forKey: "flaggers") as! [String]
				let id = self.user.objectId!
				// check if user has already flaged this content, if so, do nothing
				if ids.contains(id) {
					self.errorAlert(title: "Stay With Us...", message: "You have already flagged this post. A minimum of 2 flags is needed to erase this post permanently")

                // if this is a unique flagger, continue to flag
				} else {
                    self.errorAlert(title: "Thank you!", message: "Your flag has been reported to Workjet")
					// add user/flagger id to array of unique objects of flagger ids
					self.currentJob.addUniqueObject(self.user.objectId!, forKey: "flaggers")
					// if flagCount's exists and its value is greater than or equal to 1
					if flagCount >= 1 {
						// delete the job
						self.currentJob.deleteInBackground()
						//self.deleteUser()
						
					}
				}
			// if flagCount does not exist for current job , set its value to 1
			} else {
				self.errorAlert(title: "Thank you!", message: "Your flag has been reported to Workjet")
				number = 1
				self.currentJob.setValue(number, forKey: "flagCount")
				self.currentJob.addUniqueObject(self.user.objectId!, forKey: "flaggers")
				self.currentJob.saveInBackground()
				
			}
            alert.dismiss(animated: true, completion: nil)
			
		}))
		
		alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
			
		}))
		present(alert, animated: true, completion: nil)
		
	}
	
	func alertWithSegue(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
			self.performSegue(withIdentifier: "toHome", sender: self)
			
		}))
		present(alert, animated: true, completion: nil)
		
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
		// ignored Jobs is initialized when ever getNewJob is called
		var ignoredJobs = [String]()
        // job id of user's accepted and rejected jobs during this session is added to acceptedJobs to make list of a full viewed Jobs
		if let acceptedJobs = PFUser.current()?["accepted"] {
			ignoredJobs += acceptedJobs as! Array
			
		}
		if let rejectedJobs = PFUser.current()?["rejected"] {
			ignoredJobs += rejectedJobs as! Array
			
		}
        // get a new job that is not contained in user's accepted or rejected jobs
		query.whereKey("objectId", notContainedIn: ignoredJobs)
		query.findObjectsInBackground { (jobs, error) in
			if let jobs = jobs {
				if jobs.count > 0 {
					for job in jobs {
						self.currentJob = job
						// get job details and save this job id to viewedJobId
						self.viewedJobId = job.objectId!
						let jobTitle = job.object(forKey: "title") as! String
						self.jobTitle.text = jobTitle
						let jobRate = job.object(forKey: "rate") as! String
						self.jobRate.text = "$" + jobRate
						let jobCycle = job.object(forKey: "cycle") as! String
						self.jobCycle.text = jobCycle
						let jobDetails = job.object(forKey: "details") as! String
						self.jobDetails.text = jobDetails
						
						// get requester's photo
						let reqId = job.object(forKey: "requesterId") as! String
						// keep requester id for segue
						self.keepId = reqId
						var requester = PFObject(className: "User")
						let query: PFQuery = PFUser.query()!
						query.whereKey("objectId", equalTo: reqId)
						query.findObjectsInBackground { (users, error) in
							if let users = users {
								requester = users[0]
								let imageFile = requester.object(forKey: "image") as! PFFile
								imageFile.getDataInBackground { (data, error) in
									if let data = data {
										let imageData = NSData(data: data)
										self.reqImage.image = UIImage(data: imageData as Data)
										
									}
								}
								// enable viewProfile and infoLabel
								self.viewProfile.isHidden = false
								self.infoLabel.isHidden = false
								
							}
						}
						
						// get job location
						let geopoint = job.object(forKey: "location") as! PFGeoPoint
						let lat = geopoint.latitude
						let long = geopoint.longitude
						let location = CLLocation(latitude: lat, longitude: long)
                        // use function to get physics address and location from PFGeoPoint
						CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
							if let placemarks = placemarks {
								let placemark = placemarks[0]
								if let city = placemark.locality {
									if let countryCode = placemark.isoCountryCode {
										self.jobLocation.text = String(city) + ", " + String(countryCode)
										
									}
								}
							}
						})
					}
				} else {
                    // show alert that there are no more jobs to be viewed and segue to home on action
					self.alertWithSegue(title: "There are no more jobs around your area", message: "Please check again later")
					
				}
			}
			
			// prepare for UI Animation
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
			// animate UI elements on getNewJob() to slide in from the edges
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
							self.flagIcon.alpha = 1
			}, completion: nil)
		}
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
                let userId = user.objectId!
                let reqId = currentJob.object(forKey: "requesterId") as! String
                // enable so user cannot accept their own job
                if userId != reqId {
                    acceptedOrRejected = "accepted"
                    // add user id to array of users who accepted/swiped right for this job
                    currentJob.addUniqueObject(user.objectId!, forKey: "userAccepted")
                    currentJob.saveInBackground()
                    // animate (flip wheelbarrow horozontally) to show success
                    UIView.animate(withDuration: 3,
                                   delay: 0,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 0.0,
                                   options: [],
                                   animations: {
                                    self.wheelbarrow.transform = CGAffineTransform(rotationAngle: .pi)
                                    
                    }, completion: nil)
                    
                } else {
                    errorAlert(title: "Swipe Left", message: "WorkJet does not allow its users to accept their own jobs")
                    
                }
            } else if xFromCenter < -100 {
                acceptedOrRejected = "rejected"
                
            }
			// enable so user only sees one job once during a log in session
            if acceptedOrRejected != "" {
                PFUser.current()?.addUniqueObjects(from: [viewedJobId], forKey:acceptedOrRejected)
                PFUser.current()?.saveInBackground()
                
            }
            // recenter wheelbarrow and reset orientation
            wheelbarrow.center.x = self.view.center.x
            rotation = CGAffineTransform(rotationAngle: 0)
            stretch = rotation.scaledBy(x: 1, y: 1)
            wheelbarrow.transform = stretch
            getNewJob()
            
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
		// disable viewProfile and infoLabel except when getting new Job
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
        // hide most UI elements except when getNewJob() is called
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
		self.flagIcon.alpha = 0
        jobDetails.textContainerInset.left = 40
        
	}
	
	override func viewDidLayoutSubviews() {
		if UIDevice.current.orientation.isLandscape {
			// reform view when in landscape to push button to center of view
            // set job details initial position to prepare for animations in getNewJob
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
			// resize menuView (if present in view i.e if menuView is already being displayed) whenever orientation changes. this calculates the variable "rect" based on the new bounds
			for view in self.view.subviews {
				if view.tag == 2 {
					let xOfView = self.view.bounds.width
					let yOfView = self.view.bounds.height
					let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
					menuView.frame = rect
					
				}
			}
		} else {
            // resize menuView for portrait
            for view in self.view.subviews {
				if view.tag == 2 {
					let xOfView = self.view.bounds.width
					let yOfView = self.view.bounds.height
					let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
					menuView.frame = rect
					
				}
			}
		}
	}
	
	// hide menuView on viewDidAppear so if user presses back to return to this view, menuView is hidden. showMenu prevents the need for a double tap before menuView can be displayed again
	override func viewDidAppear(_ animated: Bool) {
		menuView.isHidden = true
		showMenu = true
		
	}
	
	@IBAction func mainMenu(_ sender: Any) {
		if showMenu {
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
			// place home view in menuView
			menuView = vc.view
			let view = menuView.subviews[1]
			// hide logo to prevent logo repeat
			view.isHidden = true
			self.view.addSubview(menuView)
			// size menuView
			let xOfView = self.view.bounds.width
			let yOfView = self.view.bounds.height
			let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
			menuView.frame = rect
			// menuView is hidden in viewDidLoad, now it is displayed
			self.menuView.isHidden = false
			self.showMenu = false

		} else {
			menuView.isHidden = true
			showMenu = true
			
		}
	}
	
	// method for users to flag explicit content
	@IBAction func flagContent(_ sender: Any) {
		flagAlert(title: "Explicit Content", message: "Are you sure you want to flag this job for explicit content?")
		
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
		showMenu = true

	}
	
}
