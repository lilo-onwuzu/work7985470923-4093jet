//
//  ViewController.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MainViewController: UIViewController {
    
    var timer = Timer()
    var countBySeconds = 0
    var font = UIFont()
    var fontSize = 70.0
    
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
        signUpButton.alpha = 0.0
        loginButton.alpha = 0.0
        registeredLabel.alpha = 0.0
        mainImage.alpha = 0.0
        
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUp", sender: self)
        
    }
    
    @IBAction func login(_ sender: AnyObject) {
        performSegue(withIdentifier: "toLogin", sender: self)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.raiseTime), userInfo: nil, repeats: true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

