//
//  Create2ViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class Create2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var cycleValue: String = ""
    var cycle = ["Flat", "Hourly", "Weekly", "Monthly", "Annually"]

    @IBOutlet weak var cyclePicker: UIPickerView!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func segue() {
        performSegue(withIdentifier: "toCreate3", sender: self)
        
    }
    
    func addCycle() {
        // save to Parse as PFObject attribute
        let query = PFQuery(className: "Job")
        query.getObjectInBackground(withId: jobId) { (job, error) in
            if error != nil {
                self.errorAlert(title: "Database Error", message: "Please try again later")
                
            } else {
                job?.add(self.cycleValue, forKey: "cycle")
                job?.saveInBackground(block: { (success, error) in
                    if error != nil {
                        self.errorAlert(title: "Database Error", message: "Please try again later")
                        
                    } else {
                        self.segue()
                        
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cyclePicker.delegate = self
        self.cyclePicker.dataSource = self
        cyclePicker.setValue(UIColor.white, forKey: "textColor")
        
    }
    
    @IBAction func createButton(_ sender: AnyObject) {
        addCycle()
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cycle.count
    
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        cycleValue = cycle[row]
        return cycle[row]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
