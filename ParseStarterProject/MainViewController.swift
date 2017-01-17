//
//  ViewController.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MainViewController: UIViewController {
    
    var timer = Timer()
    // make font, fontSize and countBySeconds global functions so they dont initialize whenever raiseTime is called
    var countBySeconds = 0
    var font = UIFont()
    var fontSize = 60.0
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registeredLabel: UILabel!
    
    func raiseTime() {
        if countBySeconds <= 650 {
            appLabel.alpha += 0.0015
            fontSize = fontSize + 0.025
            font = UIFont(name: "Dosis", size: CGFloat(fontSize))!
            appLabel.font = font
            countBySeconds += 1

        } else {
            timer.invalidate()

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hide UI elements to prepare for animation
        signUpButton.alpha = 0.0
        loginButton.alpha = 0.0
        registeredLabel.alpha = 0.0
        mainImage.alpha = 0.0

        // change view for smaller screen sizes (iPad, iPhone5 & iPhone5s)
        if UIScreen.main.bounds.height <= 600 {
            self.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // start timer on viewDidAppear and execute func "raiseTime()" at each timeInterval period
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.raiseTime), userInfo: nil, repeats: true)
        
        // animate to bring in button from edges of the view
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.signUpButton.alpha = 1.0
            self.signUpButton.center.y -= 30
            self.loginButton.alpha = 1.0
            self.loginButton.center.x -= 30
            self.registeredLabel.alpha = 1.0
            self.registeredLabel.center.x += 15
            self.mainImage.alpha = 1.0
            self.mainImage.center.y -= 30
        }, completion: nil)
        
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUp", sender: self)
        
    }
    
    @IBAction func login(_ sender: AnyObject) {
        let user = PFUser.current()!
        if user.email != nil {
            // if user is signed in. direct to home
            performSegue(withIdentifier: "toHome", sender: self)

        } else {
            performSegue(withIdentifier: "toLogin", sender: self)

        }
    }

}

