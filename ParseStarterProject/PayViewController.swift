//
//  PayViewController.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import Braintree
import UIKit

class PayViewController: UIViewController {

    var braintreeClient: BTAPIClient?
    
    @IBOutlet weak var logo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
        let clienTokenURL = NSURL(string: <#T##String#>)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
