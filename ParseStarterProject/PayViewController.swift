//
//  PayViewController.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

import Braintree
import UIKit

class PayViewController: UIViewController {

    // declare instance of client(my app) object
    var braintreeClient: BTAPIClient?
    
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var ApplePayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        
        let clientTokenURL = URL(string: "http://workjet.herokuapp.com/parse")!
        var clientTokenRequest = URLRequest(url: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest) { (data, response, error) -> Void in
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            print(clientToken!)
            print(response!)
            self.braintreeClient = BTAPIClient(authorization: clientToken!)

        }.resume()
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func pay(_ sender: Any) {

    }

    func userDidCancelPayment() {
        dismiss(animated: true, completion: nil)
        
    }

//    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce)
//    {
//        // Send payment method nonce to your server for processing
////        postNonceToServer(paymentMethodNonce.nonce)
//        dismiss(animated: true, completion: nil)
//        
//    }
//    
//    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
//        dismiss(animated: true, completion: nil)
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
