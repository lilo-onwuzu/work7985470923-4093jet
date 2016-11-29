//
//  EditJobViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import UIKit

class EditJobViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var editJob = PFObject(className: "Job")
    var cycleSelected = ""
    var cycle = ["Flat", "Hourly", "Weekly", "Monthly", "Annually"]
    var cycleValue = ""
    var status = ["Accepted", "In Progress", "Complete", "Payment Successful"]
    
    @IBOutlet weak var editTitle: UITextField!
    @IBOutlet weak var editCycle: UIPickerView!
    @IBOutlet weak var editRate: UITextField!
    @IBOutlet weak var editDetails: UITextView!
    @IBOutlet weak var editStatus: UIPickerView!
    
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
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    // if the argument "entry" is successfully converted to an optionalDouble return the optionalDouble, else, the function terminates and isNumber() has no value (no default value)
    // type cast to convert to another data type. force cast to convert from optional data type to that data type
    func isNumber(_ entry: String?) -> Double? {
        var exit: Double?
        if let entry = Double(entry!) {
            exit = entry
        }
        
        return exit
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editCycle.layer.cornerRadius = 5

        editTitle.text = (editJob.object(forKey: "title") as! String)
        editRate.text = (editJob.object(forKey: "rate") as! String)
        editDetails.text = (editJob.object(forKey: "details") as! String)
        cycleSelected = editJob.object(forKey: "cycle") as! String
        
        // set picker to job cycle value
        for index in cycle {
            if cycleSelected == index {
                editCycle.selectRow(cycle.index(of: index)!, inComponent: 0, animated: true)
            
            }
        }


    }

    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "backToJob", sender: self)
        
    }
    
    @IBAction func stepRate(_ sender: UIStepper) {
        if isNumber(editRate.text) != nil {
            editRate.text = String(isNumber(editRate.text)! + sender.value)
            sender.value = 0.0
            
        } else {
            self.editRate.text  = "1.0"
            
        }
    }

    @IBAction func saveEdit(_ sender: Any) {
        // edit title
        if self.editTitle.text != "" {
            editJob.setValue(self.editTitle.text!, forKey: "title")
            
            // edit cycle
            editJob.setValue(self.cycleValue, forKey: "cycle")
            
            // edit rate
            // confirm that rate is a valid number that is non-negative
            if isNumber(editRate.text) != nil && isNumber(editRate.text)! > 0.0 {
                editJob.setValue(self.editRate.text!, forKey: "rate")
                
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
    
    // UIPickerViewDelegate method: return an item into each row in picker and select picker value
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        cycleValue = cycle[row]
        let cycleValueAtt = NSAttributedString(string: cycleValue, attributes: [NSForegroundColorAttributeName:UIColor.white])

        return cycleValueAtt
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
