//
//  Create2ViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class Create2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var cycleValue: String = ""
    // create an array of all the items in the picker
    var cycle = ["Flat", "Hourly", "Weekly", "Monthly", "Annually"]

    @IBOutlet weak var cyclePicker: UIPickerView!
    @IBOutlet weak var logo: UILabel!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }

    func addCycle() {
        createJob.add(self.cycleValue, forKey: "cycle")
        performSegue(withIdentifier: "toCreate3", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cyclePicker.delegate = self
        self.cyclePicker.dataSource = self
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
    }
    
    @IBAction func createButton(_ sender: AnyObject) {
        addCycle()
        
    }
    
    // number of sections layed side by side in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    // number of items in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cycle.count
    
    }
    
    // return an item into each row in picker
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
