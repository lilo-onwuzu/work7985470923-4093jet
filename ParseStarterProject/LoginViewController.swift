//
//  LoginViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loginIcon: UIButton!
    @IBOutlet weak var userIcon: UIButton!
    @IBOutlet weak var passwordIcon: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func activity() {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator = UIActivityIndicatorView(frame: rect)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIView.transition(with: self.loginIcon, duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: {
        }, completion: nil)
        UIApplication.shared.beginIgnoringInteractionEvents()
      
    }
    
    func restore(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func logInAction() {
        // do not accept empty login parameters
        if username.text != "" {
            if password.text != "" {
                activity()
                let username_decap = username.text!.lowercased()
                PFUser.logInWithUsername(inBackground: username_decap, password: password.text!, block: { (user, error) in
                    self.restore()
                    // show error alerts only after restore() function to allow interactivity
                    if let error = error?.localizedDescription {
                        self.errorAlert(title: "Failed Log In", message: error)
                        
                    } else {
                        self.performSegue(withIdentifier: "toHome", sender: self)
                        
                    }
                })
            } else {
                errorAlert(title: "Invalid Password", message: "Enter a valid password")
                
            }
        } else {
            errorAlert(title: "Invalid Email", message: "Enter the email address associated with your Facebook account")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.delegate = self
        loginButton.layer.cornerRadius = 15.0
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        loginButton.alpha = 0
        backgroundImage.alpha = 0
        username.alpha = 0
        password.alpha = 0
        loginIcon.alpha = 0
        userIcon.alpha = 0
        passwordIcon.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.username.alpha = 1.0
            self.username.center.y += 10
            self.password.alpha = 1.0
            self.password.center.y += 10
            self.userIcon.alpha = 1.0
            self.userIcon.center.y -= 10
            self.passwordIcon.alpha = 1.0
            self.passwordIcon.center.y -= 10
        }, completion: nil)
        UIView.animate(withDuration: 2, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.backgroundImage.alpha = 1.0
            self.backgroundImage.center.y -= 30
        }, completion: nil)
        UIView.animate(withDuration: 2, delay: 1.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.alpha = 0.9
            self.loginButton.center.y -= 30
            self.loginIcon.alpha = 1
            self.loginIcon.center.y -= 30
        }, completion: nil)
    }
    
    @IBAction func login(_ sender: AnyObject) {
        logInAction()

    }
    
    // dismiss current VC to go back instead of using segue to go back. Segue creates a new instance or reference of the VC which could cause controller build up and your app to run of memory when excessively used.
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // tap anywhere on the screen to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // hit return to escape keyboard and login simultaneously
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        logInAction()
        return true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
