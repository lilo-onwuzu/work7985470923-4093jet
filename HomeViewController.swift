//
//  HomeViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class HomeViewController: UIViewController {
    
    // once logged in, you can access current PFUser
    let user = PFUser.current()!
    let first_image = UIImage(named: "work.jpg")!
    let second_image = UIImage(named:"work_1.jpeg")!
    let third_image = UIImage(named: "work_2.jpeg")!
    let fourth_image = UIImage(named: "work_3.jpeg")!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var jobsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var searchIcon: UIButton!
    @IBOutlet weak var createIcon: UIButton!
    @IBOutlet weak var jobsIcon: UIButton!
    @IBOutlet weak var profileIcon: UIButton!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var logOut: UIButton!
    
    func getSecondImage() {
        UIView.transition(with: self.mainImage,
                          duration: 7,
                          options: .transitionCrossDissolve,
                          animations: { self.mainImage.image = self.second_image
                            self.mainImage.alpha = 1
                            self.mainImage.contentMode = UIViewContentMode.scaleAspectFill },
                          completion: { (success) in
                            self.getThirdImage()
        })
    }
    
    func getThirdImage() {
        UIView.transition(with: self.mainImage,
                          duration: 7,
                          options: .transitionCrossDissolve,
                          animations: { self.mainImage.image = self.third_image
                            self.mainImage.alpha = 1
                            self.mainImage.contentMode = UIViewContentMode.scaleAspectFill },
                          completion: { (success) in
                            // run viewDidAppear to restart mainImage change
                            self.getFourthImage()
        })
    }
    
    func getFourthImage() {
        UIView.transition(with: self.mainImage,
                          duration: 7,
                          options: .transitionCrossDissolve,
                          animations: { self.mainImage.image = self.fourth_image
                            self.mainImage.alpha = 1
                            self.mainImage.contentMode = UIViewContentMode.scaleAspectFill },
                          completion: { (success) in
                            // run viewDidAppear to restart mainImage change
                            self.viewDidAppear(true)
        })
    }
    
    @IBAction func search(_ sender: UIButton) {
        performSegue(withIdentifier: "toSearch", sender: self)

    }

    @IBAction func profile(_ sender: AnyObject) {
        performSegue(withIdentifier: "toProfile", sender: self)
    
    }
    
    @IBAction func create(_ sender: UIButton) {
        performSegue(withIdentifier: "toCreate", sender: self)

    }
    
    @IBAction func settings(_ sender: AnyObject) {
        performSegue(withIdentifier: "toSettings", sender: self)
        
    }
    
    @IBAction func myJobs(_ sender: Any) {
        performSegue(withIdentifier: "toMyJobs", sender: self)

    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        let empty = [String]()
        // clear viewed jobs from user's filtering list then logout user
        user["accepted"] = empty
        user["rejected"] = empty
        user.saveInBackground(block: { (success, error) in
            if success {
                PFUser.logOut()

            }
        })
        performSegue(withIdentifier: "toMain", sender: self)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        searchButton.layer.cornerRadius = 10
        createButton.layer.cornerRadius = 10
        profileButton.layer.cornerRadius = 10
        settingsButton.layer.cornerRadius = 10
        jobsButton.layer.cornerRadius = 10
        
        // hide UI elements to prepare for animation in viewDidAppear
        searchButton.alpha = 0
        createButton.alpha = 0
        jobsButton.alpha = 0
        profileButton.alpha = 0
        settingsButton.alpha = 0
        userImage.alpha = 0
        
        // load user's image in main page
        let imageFile = user.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                self.userImage.image = UIImage(data: imageData as Data)
                
            }
        }
        
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 60
        searchIcon.alpha = 0
        createIcon.alpha = 0
        jobsIcon.alpha = 0
        profileIcon.alpha = 0
        settingsIcon.alpha = 0
        logOut.alpha = 0
        
        // change view for smaller screen sizes (iPad, iPhone5 & iPhone5s)
        if UIScreen.main.bounds.height <= 650 {
            self.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        // animate to present view with effects
        UIView.animate(withDuration: 0.25,
                       delay: 0.025,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: { self.searchButton.alpha = 1
                            self.createButton.alpha = 1
                            self.jobsButton.alpha = 1
                            self.profileButton.alpha = 1
                            self.settingsButton.alpha = 1
                            self.searchIcon.alpha = 1
                            self.createIcon.alpha = 1
                            self.jobsIcon.alpha = 1
                            self.profileIcon.alpha = 1
                            self.settingsIcon.alpha = 1
                            self.logOut.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 1,
                       delay: 0.5,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .transitionCrossDissolve,
                       animations: { self.searchButton.alpha = 1
                        self.userImage.alpha = 1
        }, completion: nil)
        UIView.transition(with: self.mainImage,
                          duration: 7,
                          options: .transitionCrossDissolve,
                          animations: { self.mainImage.image = self.first_image
                            self.mainImage.alpha = 1
                            self.mainImage.contentMode = UIViewContentMode.bottomRight },
                          completion: { (success) in
                            self.getSecondImage()
        })
    }
}
