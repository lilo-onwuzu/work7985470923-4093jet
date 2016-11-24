//
//  Create3ViewController.swift
//
//  Created by mac on 10/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//


import UIKit

class Create3ViewController: UIViewController, UITextFieldDelegate {
    
    var createJob = PFObject(className: "Job")

    @IBOutlet weak var rateField: UITextField!
    @IBOutlet weak var rateStepper: UIImageView!
    @IBOutlet weak var logo: UILabel!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
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
        // Called on touch up inside. If isNumber() has a value i.e rateField already has a valid number, add the number to the stepper value, else add 0
        var enterRate: Double? = 0.0
        if isNumber(rateField.text) != nil {
            enterRate = isNumber(rateField.text)! + sender.value
            sender.value = 0.0
        
        }
        rateField.text = String(enterRate!)
    }
    
    @IBAction func createButton(_ sender: AnyObject) {
        // before redirecting, confirm that rate still has a valid number that is non-negative
        if isNumber(rateField.text) != nil && isNumber(rateField.text)! > 0.0 {
            createJob.setValue(self.rateField.text!, forKey: "rate")
            performSegue(withIdentifier: "toCreate4", sender: self)
            
        } else {
            errorAlert(title: "Invalid Entry", message: "Please enter a valid rate")
            
        }
    }
    
    @IBAction func back(_ sender: Any) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreate4" {
            let nextVC = segue.destination as! Create4ViewController
            nextVC.createJob = self.createJob
            
        }
    }

}
