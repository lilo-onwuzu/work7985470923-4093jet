//
//  SignUpViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit
import FacebookCore
import FacebookLogin

class SignUpViewController: UIViewController, LoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var bar: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var enterPassword: UITextField!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var facebookIcon: UIButton!
    
    // initialize new empty PFUser object for new user
    let user: PFUser = PFUser()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    // initialize new boolean to verify successful login and facebook user detail collection
    var loggedIn: Bool = Bool()
    // initialize facebook login delegate button (permissions the delegate to get info in [] array
    let facebookButton = LoginButton(readPermissions: [ .publicProfile , .email ])
    
    func activity() {
        // position rect to receive activity indicator
        let rect: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator = UIActivityIndicatorView(frame: rect)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        // add initialized activity indicator object to view
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        // ignore all user interactions during login activity
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    
    func restore(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            // once user clicks the action button "OK", dismiss the UIAlertController and its corresponding view
            alert.dismiss(animated: true, completion: nil)
        
        }))
        // present UIAlertController view controller to current view's view controller
        present(alert, animated: true, completion: nil)
        
    }
    
    func signedUpAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
            // once user clicks the action button "OK", dismiss the UIAlertController and its corresponding view and segue to login screen
            self.performSegue(withIdentifier: "toMain", sender: self)
            alert.dismiss(animated: true, completion: nil)
            
        }))
        // present UIAlertController view controller to current view's view controller
        present(alert, animated: true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // assign textfield's delegate to view controller to allow view controller to control the password textfield
        // view controller as already been subclassed as a UITextFieldDelegate
        self.password.delegate = self
        // display Facebook login button and position rect to receive login button
        facebookButton.frame = CGRect(x: (self.view.bounds.width / 2) - 25, y: (self.view.bounds.height / 2) - 13, width: 50, height: 50)
        // facebookButton does not exist in MainStoryboard so add it to view
        view.addSubview(facebookButton)
        // assign login button's delegate to view controller to allow view controller to log in to facebook
        // view controller as already been subclassed as a LoginButtonDelegate
        facebookButton.delegate = self
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        // get new user's location 
        // there is no error checking in this block of code so remember to use "if let" during get a user location operation to prevent crash
        PFGeoPoint.geoPointForCurrentLocation { (coordinates, error) in
            if let coordinates = coordinates {
                self.user.setValue(coordinates, forKey: "location")
                
            }
        }
        // hide UI elements to prepare for animation
        bar.alpha = 0
        signUpButton.alpha = 0
        enterPassword.alpha = 0
        mainImage.alpha = 0
        facebookButton.alpha = 0
        facebookIcon.alpha = 0
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // UIAnimation bypasses constraints and moves the view as defined
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.mainImage.alpha = 1.0
            self.bar.alpha = 1.0
            self.bar.center.y -= 30
        }, completion: nil)
        UIView.animate(withDuration: 2, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.signUpButton.alpha = 1.0
            self.signUpButton.center.y -= 30
            self.enterPassword.alpha = 1.0
            self.enterPassword.center.y -= 30
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.75, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.facebookIcon.alpha = 1
            self.facebookButton.alpha = 0.05
        }, completion: nil)
        
    }
    
    // FBSDKLoginDelegate method
    // add facebook login details before sign up
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        activity()
        let parameters = ["fields": "email, first_name, last_name"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            // be careful with "let" statement. Only use them for certainly controllable events
            // when communicating with an external SDK, try to use the "if let" block where necessary so app does not crash if SDK changes and requests are unsuccessful
            // try ("as?") to cast the result of the graph request as a dictionary, if successful, continue with the product as a new variable "result", if that fails for any reason, result does not exist because it was never initialized, function terminates with no crash
            if let result = result as? NSDictionary {
                if let email = result.object(forKey: "email") as? String {
                    if let firstName = result.object(forKey: "first_name") as? String {
                        if let lastName = result.object(forKey: "last_name") as? String {
                            if let facebookId = result.object(forKey: "id") as? String {
                                self.facebookButton.isHidden = true
                                self.facebookIcon.isHidden = true
                                // add user attributes to PFUser object first
                                self.user.username = email
                                self.user.email = email
                                self.user["first_name"] = firstName
                                self.user["last_name"] = lastName
                                self.user["facebookId"] = facebookId
                                // display welcome message and restore app interactivity
                                self.name.text = "Welcome, " + firstName + " " + lastName + "!"
                                // once user has logged in and details collected, set Boolean to true
                                self.loggedIn = true
                                // import FB photo if possible
                                let url = "https://graph.facebook.com/" + facebookId + "/picture?type=large"
                                let imageUrl = NSURL(string: url)!
                                // try to make imageData object  but do not force cast with "!". The result is an optional NSData object. It will be ignored it unsuccessful
                                let imageData = NSData(contentsOf: imageUrl as URL)
                                // use "if let" conditional to prevent crash if imageData object is not successully cast. The result of the  "if let" conditional below is "imageData": a non-optional NSData object
                                if let imageData = imageData {
                                    let imageFile: PFFile = PFFile(data: imageData as Data)!
                                    self.user["image"] = imageFile
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        self.restore()
        
    }
    
    // FBSDKLoginDelegate method. Not needed, login button is hidden after successful login activity
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        // signup allowed only when password is valid and FB login is successful else show error alert
        if password.text != "" {
            self.activity()
            user.password = password.text
            // check if facebook login was successful and details retrieved
            if self.loggedIn {
                // save PFUser object to Parse. Save will happen only if all the keys are present else display error
                user.signUpInBackground(block: { (success, error) in
                    self.restore()
                    if success {
                        self.signedUpAlert(title: "Successful!", message: "Thanks for signing up.")
                        
                    } else {
                        if let error = error?.localizedDescription {
                            // display sign up error message
                            self.errorAlert(title: "Failed Sign Up", message: error)
                            
                        }
                    }
                })
            } else {
                self.restore()
                errorAlert(title: "Invalid Facebook Login", message: "You need to log in with Facebook to sign up with WorkJet")
                
            }
        } else {
            errorAlert(title: "Invalid Password", message: "Please enter a valid password")
            
        }
    }
  
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
