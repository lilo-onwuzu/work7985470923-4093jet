//
//  LoginViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

// ISSUES: Show actual errors
// Text Fields not visible in Main Storyboard
// Press "enter" to "login"

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
        
    }
    
    @IBAction func login(_ sender: AnyObject) {
        
        if username.text != "" {
            
            if password.text != "" {
                
                activity()
                
                PFUser.logInWithUsername(inBackground: username.text!, password: password.text!, block: { (user, error) in
                    self.restore()
                    if error != nil {
                        self.errorAlert(title: "Failed Log In", message: "An error occcured during log in")
                    } else {
                        self.performSegue(withIdentifier: "toHome", sender: self)
                    }
                })
                
            } else {
                errorAlert(title: "Invalid Passrord", message: "Please enter a valid password")
            }
            
        } else {
            errorAlert(title: "Invalid Username", message: "Please enter a valid username")
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
