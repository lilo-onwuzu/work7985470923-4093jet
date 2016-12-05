//
//  Create4ViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class Create4ViewController: UIViewController, UITextFieldDelegate {
    
    let text_field_limit = 300
    var createJob: PFObject = PFObject(className: "Job")

    @IBOutlet weak var jobDetails: UITextField!
    @IBOutlet weak var logo: UILabel!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
       
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func addDetails() {
        if jobDetails.text != "" {
            if jobDetails.text != "Include more information here..." {
                createJob.setValue(self.jobDetails.text! , forKey: "details")
                // finally save "createJob" PFObject to Parse
                // saveInBackground is an asychronous call that does not wait to execute before continuing so save it with block if you need data that is returned from the async call
                createJob.saveInBackground(block: { (success, error) in
                    if success {
                        // wait till finish is true or createJob object is saved in async call before segue
                        self.performSegue(withIdentifier: "toConfirm", sender: self)
                        
                    } else {
                        self.errorAlert(title: "Database Error", message: "Please try again later")
                    }

                })
            } else {
                errorAlert(title: "Invalid Form Entry", message: "Please enter valid details")
                
            }
        } else {
            errorAlert(title: "Invalid Form Entry", message: "Please add some more details")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.jobDetails.delegate = self
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
    }
    
    @IBAction func confirmCreate(_ sender: AnyObject) {
        addDetails()
        
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        jobDetails.resignFirstResponder()
        addDetails()
        return true

    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= text_field_limit
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
