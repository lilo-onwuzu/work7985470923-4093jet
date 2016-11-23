//
//  EditJobViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import UIKit

class EditJobViewController: UIViewController {

    @IBOutlet weak var editTitle: UITextField!
    @IBOutlet weak var editCycle: UIPickerView!
    @IBOutlet weak var editRate: UITextField!
    @IBOutlet weak var editDetails: UITextField!
    @IBOutlet weak var editStatus: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveEdit(_ sender: Any) {
    
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
