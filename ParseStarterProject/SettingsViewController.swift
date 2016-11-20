//
//  SettingsViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//

// connect apple pay 
// scrollable page

import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let user = PFUser.current()!
    var confirm = false
    let image = UIImagePickerController()

    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var photoLibrary: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var changedPassword: UILabel!
    @IBOutlet weak var deletedAccount: UILabel!
    @IBOutlet weak var changedPhoto: UILabel!

    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No I'll Stay", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            // set confirm to true to run PFUser delete
            self.confirm = true
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        photoLibrary.layer.cornerRadius = 3
        camera.layer.cornerRadius = 3
        // UIImagePickerController's delegate object is of type UIImagePickerControllerDelegate and UINavigationControllerDelegate
        // a delegate of an object (e.g UITableViewDelegate) is a "protocol" that allows the object (UITableView) to be manipulated by calling functions with the object as an arguments. These functions or methods on the object can now be called anywhere within the delegate (self or settingsVC in this case)
        image.delegate = self
        scrollView.contentSize.height = 1000
        
    }
    
    @IBAction func home(_ sender: AnyObject) {
        performSegue(withIdentifier: "toHome", sender: self)
        
    }
    
    @IBAction func change(_ sender: UIButton) {
        if password.text != "" {
            user.password = password.text
            user.saveInBackground { (success, error) in
                if success {
                    self.changedPassword.text = "Your password has been updated!"
                    
                } else {
                    if let error = error {
                        self.errorAlert(title: "Update Password Error", message: error.localizedDescription)
                        
                    }
                }
            }
        }
    }
    
    @IBAction func `import`(_ sender: Any) {
        photoLibrary.isHidden  = false
        camera.isHidden = false
    
    }
    
    @IBAction func library(_ sender: UIButton) {
        // lets UIImagePickerController object know where to pick image from
        image.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)

    }
    
    @IBAction func camera(_ sender: UIButton) {
        image.sourceType = UIImagePickerControllerSourceType.camera
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteUser(_ sender: Any) {
        deleteAlert(title: "Confirm Delete Account", message: "Are you sure you want to delete your account?")
        if confirm {
            user.deleteInBackground { (success, error) in
                if success {
                    self.deletedAccount.text = "Your account has been deleted. Thanks for using WorkJet"
                    
                } else {
                    if let error = error {
                        self.errorAlert(title: "Account Delete Error", message: error.localizedDescription)
                    
                    }
                }
            }
        }
    }
    
    // run after UIImagePickerController has succesfully gotten a selected image, update Parse
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageData = UIImagePNGRepresentation(pickedImage)!
            let imageFile = PFFile(data: imageData)!
            user["image"] = imageFile
            changedPhoto.text = "Your photo has been updated"
            
        }
        self.dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
