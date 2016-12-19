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
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var formLabel: UILabel!
    @IBOutlet weak var createIcon: UIButton!
    
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
                        // wait till finish is true or createJob object is saved in async call before confirming
                        // hide background
                        self.jobDetails.isHidden = true
                        self.formLabel.isHidden = true
                        self.createButton.isHidden = true
                        // display confirmation
                        self.confirmLabel.isHidden = false
                        self.homeButton.isHidden = false
                        self.confirmLabel.layer.masksToBounds = true
                        self.confirmLabel.layer.cornerRadius = 5
                        self.homeButton.layer.cornerRadius = 5
                        UIView.transition(with: self.createIcon, duration: 2,
                                          options: .transitionFlipFromLeft,
                                          animations: {
                                            self.createIcon.setImage(UIImage(named: "caseIcon.png"), for:.normal)
                        }, completion: nil)
                        
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
        formLabel.alpha = 0
        jobDetails.alpha = 0
        createButton.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.formLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.jobDetails.alpha = 0.5
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.025, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.createButton.alpha = 0.8
        }, completion: nil)
        
    }
    
    @IBAction func confirmCreate(_ sender: AnyObject) {
        addDetails()
        
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func home(_ sender: Any) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        jobDetails.resignFirstResponder()
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
