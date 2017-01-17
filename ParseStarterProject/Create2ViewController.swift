//
//  Create2ViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class Create2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var createJob = PFObject(className: "Job")
    // set initial value to flat because UIPickerView delegate's method didSelectRow is only called when there is a change from the initial value 
    var cycleValue = "Flat"
    // create an array of all the items in the picker
    var cycle = ["Flat", "Hourly", "Weekly", "Monthly", "Annually"]

    @IBOutlet weak var cyclePicker: UIPickerView!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var nextButton: UIButton!
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

    func addCycle() {
        createJob.setValue(self.cycleValue, forKey: "cycle")
        performSegue(withIdentifier: "toCreate3", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cyclePicker.delegate = self
        self.cyclePicker.dataSource = self
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        cyclePicker.layer.masksToBounds = true
        cyclePicker.layer.cornerRadius = 7
        
        // change view for smaller screen sizes (iPad, iPhone5 & iPhone5s)
        if UIScreen.main.bounds.height <= 650 {
            self.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
        }
        
    }
    
    @IBAction func createButton(_ sender: AnyObject) {
        addCycle()
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // UIPickerViewDelegate method: number of sections layed side by side in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    // UIPickerViewDelegate method: return an attributed form of each value in cycle array into each row in picker
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
            
        }
        var cycleRow = ""
        cycleRow = cycle[row]
        let title = NSAttributedString(string: cycleRow, attributes: [NSFontAttributeName: UIFont.init(name: "Offside", size: 22.0)! ,                                     NSForegroundColorAttributeName: UIColor.white])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
        
    }
    
    // UIPickerViewDelegate method: number of items in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cycle.count
    
    }
    
    // UIPickerViewDelegate method: get selected row value. Save selected cycle in variable "cycleValue"
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cycleValue = cycle[row]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass PFObject through segue without saving to Parse yet
        if segue.identifier == "toCreate3" {
            let nextVC = segue.destination as! Create3ViewController
            nextVC.createJob = self.createJob
            
        }
    }

}
