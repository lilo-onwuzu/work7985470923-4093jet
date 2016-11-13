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
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    // initialize new empty PFUser object
    let user: PFUser = PFUser()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loggedIn: Bool = false
    
    func activity() {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator = UIActivityIndicatorView(frame: rect)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.delegate = self
        // display Facebook login button
        let signUpButton = LoginButton(readPermissions: [ .publicProfile ])
        signUpButton.frame = CGRect(x: (self.view.bounds.width / 2) - 100, y: (self.view.bounds.height / 2) - 25 , width: 200, height: 25)
        view.addSubview(signUpButton)
        signUpButton.delegate = self
        
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
                                // add user attributes to PFUser object first
                                self.user.username = email
                                self.user.email = email
                                self.user["first_name"] = firstName
                                self.user["last_name"] = lastName
                                self.user["facebookId"] = facebookId
                                // hide facebook login button
                                loginButton.isHidden = true
                                // display welcome message and restore app interactivity
                                self.name.text = "Welcome, " + firstName + " " + lastName + " !"
                                self.restore()
                                self.loggedIn = true
                                // import FB photo if possible
                                let url = "https://graph.facebook.com/" + facebookId + "/picture?type=large"
                                let imageUrl = NSURL(string: url)!
                                // try to make imageData object  but do not force cast with "!". This result is an optional NSData object
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
    }
    
    // FBSDKLoginDelegate method. Not needed, login button is hidded after successful login activity
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        // add initialized PFUser object to Parse
        // signup allowed only when password is true and FB login is successful else show error alert
        if password.text != "" {
            self.activity()
            user.password = password.text
            // check if facebook login was successful and details retrieved
            if self.loggedIn {
                // save PFUser object to Parse. Save will happen only if all the keys are present
                user.signUpInBackground(block: { (success, error) in
                    self.restore()
                    if success {
                        self.performSegue(withIdentifier: "toMain", sender: self)
                        
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
    
    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "toMain", sender: self)
        
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
