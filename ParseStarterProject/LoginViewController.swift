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
    @IBOutlet weak var signUpButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func activity() {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator = UIActivityIndicatorView(frame: rect)
        activityIndicator.center = view.center
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
    
    func logInAction() {
        // do not accept empty login parameters
        if username.text != "" {
            if password.text != "" {
                activity()
                let username_decap = username.text!.lowercased()
                PFUser.logInWithUsername(inBackground: username_decap, password: password.text!, block: { (user, error) in
                    self.restore()
                    // show error alerts only after restore() function to allow interactivity
                    if error != nil {
                        self.errorAlert(title: "Failed Log In", message: "You entered an invalid email or password")
                        
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
        loginButton.layer.cornerRadius = 5.0
        signUpButton.layer.cornerRadius = 5.0

    }
    
    @IBAction func login(_ sender: AnyObject) {
        logInAction()
        
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        performSegue(withIdentifier: "backToSignUp", sender: self)
        
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
