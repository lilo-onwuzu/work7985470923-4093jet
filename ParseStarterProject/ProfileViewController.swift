//
//  ProfileViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let image = UIImagePickerController()
    let user = PFUser.current()!

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var editStory: UITextField!
    @IBOutlet weak var userStory: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func runEdit() {
        let editStory = self.editStory.text!
        // update displayed user story
        userStory.text = editStory
        // update user story in Parse
        user["story"] = editStory
        // save
        user.saveInBackground(block: { (success, error) in
            if let error = error?.localizedDescription {
                self.errorAlert(title: "Database Error", message: error)
        
            } else {
                self.editStory.text = "Your story has been updated!"
        
            }
        })
        userStory.sizeToFit()
        scrollView.sizeToFit()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        // UIImagePickerController's delegate object is of type UIImagePickerControllerDelegate and UINavigationControllerDelegate
        // a delegate of an object (e.g UITableViewDelegate) is a "protocol" that allows the object (UITableView) to be manipulated by calling functions with the object as an arguments. These functions or methods on the object can now be called anywhere within the delegate (self or settingsVC in this case)
        image.delegate = self
        editStory.delegate = self
        let firstName = user.object(forKey: "first_name") as! String
        let lastName = user.object(forKey: "last_name") as! String
        userName.text = firstName + " " + lastName
        // if story already exists for user, convert it to string (if possible- no "!") and display it
        if let story = user.object(forKey: "story") {
            userStory.text = String(describing: story)
        
        }
        userStory.sizeToFit()
        // display user's saved image. user image data always exists in Parse
        let imageFile = user.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                self.userImage.image = UIImage(data: imageData as Data)
            
            }
        }
        
    }

    @IBAction func changePhoto(_ sender: Any) {
        // lets UIImagePickerController object know where to pick image from
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
        
    }
    
    // edit action executes "after editing ends" or return button is tapped
    @IBAction func edit(_ sender: AnyObject) {
        runEdit()
        
    }
    
    // dismiss current VC to go back instead of using segue to go back. Segue creates a new instance or reference of the VC which could cause controller build up and your app to run of memory when excessively used.
    @IBAction func home(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    
    }
    
    // run after UIImagePickerController has succesfully gotten a selected image, updates Parse with new image and changes displayed image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageData = UIImageJPEGRepresentation(pickedImage, 0.5)!
            let imageFile = PFFile(data: imageData)!
            user["image"] = imageFile
            user.saveInBackground()
            userImage.image = pickedImage
            
        }
        self.dismiss(animated: true, completion: nil)
        
    }

    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        runEdit()
        return true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
