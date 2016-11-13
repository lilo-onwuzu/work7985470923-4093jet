//
//  Create4ViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class Create4ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var jobDetails: UITextField!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
       
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func addDetails() {
        if jobDetails.text != "" || jobDetails.text != "Include more information here..." {
            let query = PFQuery(className: "Job")
            query.getObjectInBackground(withId: jobId) { (job, error) in
                if error != nil {
                    self.errorAlert(title: "Parse Fetch Error", message: "Please try again later")
                    
                } else {
                    job?.add(self.jobDetails.text! , forKey: "details")
                    
                    job?.saveInBackground(block: { (success, error) in
                        if error != nil {
                            self.errorAlert(title: "Parse Save Error", message: "Please try again later")
                            print(error)
                            
                        } else {
                            
                        }
                    })
                }
            }
            self.performSegue(withIdentifier: "toConfirm", sender: self)
        } else {
            errorAlert(title: "Invalid Form Entry", message: "Please add some more details")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.jobDetails.delegate = self
        
    }
    
    @IBAction func confirmCreate(_ sender: AnyObject) {
        addDetails()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        jobDetails.resignFirstResponder()
        addDetails()
        return true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}
