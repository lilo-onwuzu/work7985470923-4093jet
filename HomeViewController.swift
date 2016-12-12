//
//  HomeViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


// add animations

import UIKit

class HomeViewController: UIViewController {
    
    let user = PFUser.current()!
    let first_image = UIImage(named: "work.jpg")!
    let second_image = UIImage(named:"work_1.jpeg")!
    let third_image = UIImage(named: "work_2.jpeg")!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var jobsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    
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
        searchButton.layer.cornerRadius = 10
        createButton.layer.cornerRadius = 10
        profileButton.layer.cornerRadius = 10
        settingsButton.layer.cornerRadius = 10
        jobsButton.layer.cornerRadius = 10
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3

    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
