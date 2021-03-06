//
//  Create3ViewController.swift
//
//  Created by mac on 10/14/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class Create3ViewController: UIViewController, UITextFieldDelegate {
    
    var createJob = PFObject(className: "Job")

    @IBOutlet weak var rateField: UITextField!
    @IBOutlet weak var rateStepper: UIStepper!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var label: UILabel!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add alert action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        
        // present
        present(alert, animated: true, completion: nil)
        
    }
    
    // if the argument "entry" is successfully converted to an optionalDouble return the optionalDouble, else, the function terminates and isADouble() has nil value)
    func isADouble(_ entry: String?) -> Double? {
        var exit: Double?
        
        if let entry = Double(entry!) {
            exit = entry
            
        }
        
        return exit
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
        // change view for smaller screen sizes (iPad, iPhone5 & iPhone5s)
        if UIScreen.main.bounds.height <= 650 {
            self.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
        }
        
    }
    
    // called on touch up inside. checks to see if rateField has a value that can be converted into a Double
    @IBAction func stepRate(_ sender: UIStepper) {
        var enterRate: Double?
        
        // if a double, save to enterRate
        if isADouble(rateField.text) != nil {
            // if isADouble(), add to the stepper value (+ve or -ve)
            enterRate = isADouble(rateField.text)! + sender.value
            sender.value = 0.00
            
        // if not a double or textField is empty, show "1.00" on first tap
        } else {
            enterRate = 1.00
            // zero sender.value so it does not change on first tap
            sender.value = 0.00
            
        }
        
        // display enterRate value in textField on every tap
        rateField.text = String(format: "%.2f", enterRate!)
        
    }
    
    @IBAction func next(_ sender: Any) {
        let rate = String(format: "%.2f", isADouble(rateField.text)!)
        
        // before redirecting, confirm that rate still has a valid number that is non-negative
        if isADouble(rateField.text) != nil && isADouble(rateField.text)! > 0 {
            createJob.setValue(rate, forKey: "rate")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass PFObject through segue without saving to Parse
        if segue.identifier == "toCreate4" {
            let nextVC = segue.destination as! Create4ViewController
            nextVC.createJob = self.createJob
            
        }
    }

}
