//
//  Create3ViewController.swift
//  ParseStarterProject
//
//  Created by mac on 10/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

// ISSUES: Show actual error
// add $ sign

import UIKit

class Create3ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var rateField: UITextField!
    @IBOutlet weak var rateStepper: UIImageView!
    
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

    @IBAction func beginEditRate(_ sender: UITextField) {
        // rateField.text = "$"

    }
    
    // if the argument "entry" is successfully converted to an optionalDouble return the optionalDouble, else, the function terminates and isNumber() has no value (no default value)
    func isNumber(_ entry: String?) -> Double? {
        var exit: Double?
        if let entry = Double(entry!) {
            exit = entry
        }
        return exit
        
    }
    
    @IBAction func stepRate(_ sender: UIStepper) {
        // if isNumber() has a value i.e rateField already has a valid number, add the number to the stepper value, else add 0
        var enterRate: Double? = 0.0
        if isNumber(rateField.text) != nil {
            enterRate = isNumber(rateField.text)! + sender.value
            sender.value = 0.0
        }
        rateField.text = String(enterRate!)
        
    }
    
    @IBAction func createButton(_ sender: AnyObject) {
        // before rediecting, confirm that rate still has a valid number that is non-negative
        if isNumber(rateField.text) != nil && isNumber(rateField.text)! > 0.0 {
            // save to Parse as PFObject attribute
            let query = PFQuery(className: "Job")
            query.getObjectInBackground(withId: jobId) { (job, error) in
                if error != nil {
                    self.errorAlert(title: "Parse Fetch Error", message: "Please try again later")
                    
                } else {
                    job?.add(self.rateField.text! , forKey: "rate")

                    job?.saveInBackground(block: { (success, error) in
                        if error != nil {
                            self.errorAlert(title: "Parse Save Error", message: "Please try again later")
                            print(error)
                        
                        } else {
                            self.performSegue(withIdentifier: "toCreate4", sender: self)
                        }
                    })
                }
            }
            
        } else {
            errorAlert(title: "Invalid Entry Error", message: "Please enter a valid rate")
            
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
