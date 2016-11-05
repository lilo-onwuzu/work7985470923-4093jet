//
//  SignUpViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

// ISSUES:  remove logOut access and direct to facebook login screen first.
// FB button takes a while to load
// show actual error messages

import UIKit
import FacebookCore
import FacebookLogin

class SignUpViewController: UIViewController, LoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loggedIn: Bool = false
    let user = PFUser()
    
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
        
        // display Facebook login button
        let signUpButton = LoginButton(readPermissions: [ .publicProfile ])
        let origin = CGPoint(x:145, y:600)
        let size = CGSize(width: 150, height: 25)
        signUpButton.frame = CGRect(origin: origin, size: size)
        view.addSubview(signUpButton)
        
        signUpButton.delegate = self
        
    }
    
    // log in with facebook
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        let parameters = ["fields": "email, first_name, last_name"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            
            if let result = result {
                // display activity indicator and ignore interactions during FB login
                self.activity()
                
                // collect FBSDKGraph info
                let result = result as! NSDictionary
                let email = result.object(forKey: "email") as! String
                let firstName = result.object(forKey: "first_name") as! String
                let lastName = result.object(forKey: "last_name") as! String
                let facebookId = result.object(forKey: "id") as! String
                
                // save user to Parse and display
                self.user.username = email
                self.user.email = email
                self.user["first_name"] = firstName
                self.user["last_name"] = lastName
                self.user["facebookId"] = facebookId
                self.name.text = "Welcome, " + firstName + " " + lastName + " !"
                self.loggedIn = true
                
                // import FB photo if possible
                let url = "https://graph.facebook.com/" + facebookId + "/picture?type=large"
                let imageUrl = NSURL(string: url)!
                // when communicating with an external SDK, try to use the "if let" block where necessary so app does not crash if SDK changes and requests are unsuccessful
                let imageData = NSData(contentsOf: imageUrl as URL)!
                if imageData == imageData {
                    self.image.image = UIImage(data: imageData as Data)!
                    let imageFile: PFFile = PFFile(data: imageData as Data)!
                    self.user["image"] = imageFile
                    self.restore()
                } else {
                    self.restore()
                    self.errorAlert(title: "Facebook Photo Import Error", message: "Please try again later")
                }
            
            // else show Facebook Request Error Alert and terminate function
            } else {
                self.errorAlert(title: "Facebook Login Error", message: "Please try again later")
                
            }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        // signup allowed only when password is true and FB login is successful else show error alert
        if password.text != "" {
            self.activity()
            user.password = password.text
            // checks if facebook login was successful and details retrieved
            if self.loggedIn {
                user.signUpInBackground(block: { (success, error) in
                    self.restore()
                    if success {
                        self.performSegue(withIdentifier: "toMain", sender: self)
                    } else {
                        self.errorAlert(title: "Failed Sign Up", message: "An error occured during sign up. Please try again")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
