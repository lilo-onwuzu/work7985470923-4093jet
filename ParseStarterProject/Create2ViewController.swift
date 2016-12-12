//
//  Create2ViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class Create2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var createJob = PFObject(className: "Job")
    var cycleValue: String = ""
    // create an array of all the items in the picker
    var cycle = ["Flat", "Hourly", "Weekly", "Monthly", "Annually"]

    @IBOutlet weak var cyclePicker: UIPickerView!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
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
        nextButton.alpha = 0
        cyclePicker.alpha = 0
        label.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.label.alpha = 1
            self.label.center.x += 0
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.cyclePicker.alpha = 0.8
            self.cyclePicker.center.x += 0
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.nextButton.alpha = 0.9
            self.nextButton.center.x += 0
        }, completion: nil)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass PFObject through segue without saving to Parse
        if segue.identifier == "toCreate3" {
            let nextVC = segue.destination as! Create3ViewController
            nextVC.createJob = self.createJob
            
        }
    }

}
