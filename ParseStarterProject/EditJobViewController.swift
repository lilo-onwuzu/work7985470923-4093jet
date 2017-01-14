//
//  EditJobViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class EditJobViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var editJob = PFObject(className: "Job")
    var cycle = ["Flat", "Hourly", "Weekly", "Monthly", "Annually"]
    var cycleValue = "Flat"
    var cycleSelected = ""

    @IBOutlet weak var editTitle: UITextField!
    @IBOutlet weak var editCycle: UIPickerView!
    @IBOutlet weak var editRate: UITextField!
    @IBOutlet weak var editDetails: UITextView!
    @IBOutlet weak var logo: UILabel!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveAlert(title: String, message: String, job: PFObject) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Yes Save", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            // set confirm to true to run PFUser delete
            job.saveInBackground { (success, error) in
                if let error = error {
                    self.errorAlert(title: "Error Editing Job", message: error.localizedDescription + ". Please try again")
                    
                } else {
                    self.performSegue(withIdentifier: "backToTab", sender: self)
                    
                }
            }
        }))
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
        editCycle.layer.cornerRadius = 5
        editTitle.text = (editJob.object(forKey: "title") as! String)
        editRate.text = (editJob.object(forKey: "rate") as! String)
        editDetails.text = (editJob.object(forKey: "details") as! String)
        self.editCycle.delegate = self
        self.editCycle.dataSource = self
        // set jobCycle as selected row in cyclePicker
        cycleSelected = editJob.object(forKey: "cycle") as! String
        // set picker to job cycle value
        for index in cycle {
            if cycleSelected == index {
                editCycle.selectRow(cycle.index(of: index)!, inComponent: 0, animated: true)
                
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func stepRate(_ sender: UIStepper) {
        var enterRate: Double?
        // if a double
        if isADouble(editRate.text) != nil {
            // if isADouble(), add to the stepper value (+ve or -ve)
            enterRate = isADouble(editRate.text)! + sender.value
            sender.value = 0.00
            
            // if not a double or textField is empty, show "1.00" on first tap
        } else {
            enterRate = 1.00
            // zero sender.value so it does not change on first tap
            sender.value = 0.00
            
        }
        // display enterRate value in textField on every tap
        editRate.text = String(format: "%.2f", enterRate!)
        
    }

    @IBAction func saveEdit(_ sender: Any) {
        // edit title
        if self.editTitle.text != "" {
            editJob.setValue(self.editTitle.text!, forKey: "title")
            // edit cycle
            editJob.setValue(self.cycleValue, forKey: "cycle")
            
            // edit rate
            let rate = String(format: "%.2f", isADouble((editRate.text)!)!)
            // confirm that rate is a valid number that is non-negative
            if isADouble(editRate.text) != nil && isADouble(editRate.text)! > 0.0 {
                editJob.setValue(rate, forKey: "rate")
                
                // edit Details
                if editDetails.text != "" {
                    editJob.setValue(self.editDetails.text! , forKey: "details")
                    // finally, save job
                    saveAlert(title: "Confirm Edit", message: "Are you sure you want to edit this job", job: editJob)

                } else {
                    errorAlert(title: "Invalid Form Entry", message: "Please add some more details")
                    
                }
            } else {
                errorAlert(title: "Invalid Entry", message: "Please enter a valid rate")
                
            }
        } else {
            self.errorAlert(title: "Invalid Entry", message: "Please add a job title")
            
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
    
    // UIPickerViewDelegate method: number of sections layed side by side in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    // UIPickerViewDelegate method: number of items in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cycle.count
        
    }
    
    // UIPickerViewDelegate method: get selected row value
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cycleValue = cycle[row]

    }
    
    // UIPickerViewDelegate method: return an attributed from of each value in cycle array into each row in picker
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        var cycleRow = ""
        cycleRow = cycle[row]
        let title = NSAttributedString(string: cycleRow, attributes: [NSFontAttributeName: UIFont.init(name: "Offside", size: 22.0)! , NSForegroundColorAttributeName: UIColor.black ])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
        
    }

}
