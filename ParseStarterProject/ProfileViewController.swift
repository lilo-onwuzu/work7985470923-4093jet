//
//  ProfileViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var showMenu = true
    let text_field_limit = 600
    let image = UIImagePickerController()
    let user = PFUser.current()!
    // setting changingPhoto to false allows the camera and photos button to be displayed and the overlapping view to slide down
    var changingPhoto = true
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var editStory: UITextField!
    @IBOutlet weak var userStory: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    // saves new story for user
    func runEdit() {
        let editStory = self.editStory.text!
        // update displayed user story
        userStory.text = editStory
        // update user story in Parse
        user["story"] = editStory
        // save to Parse
        user.saveInBackground(block: { (success, error) in
            if let error = error?.localizedDescription {
                self.errorAlert(title: "Database Error", message: error)
        
            } else {
                self.editStory.text = "Your story has been updated!"
                self.userStory.sizeToFit()

            }
        })
    }
    
    func showPhotoBar() {
        if changingPhoto {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.scrollView.center.y += 50
                self.cameraButton.isHidden = false
                self.photosButton.isHidden = false
                self.changingPhoto = false
            }, completion: nil)
        }
    }
    
    func hidePhotoBar() {
        if !changingPhoto {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.scrollView.center.y -= 50
                self.cameraButton.isHidden = true
                self.photosButton.isHidden = true
                self.changingPhoto = true
            }, completion: nil)
        }
    }
    
    func displayMenu() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        // place home view in menuView
        menuView = vc.view
        let view = menuView.subviews[1]
        // hide logo to prevent logo repeat
        view.isHidden = true
        self.view.addSubview(menuView)
        // size menuView
        let xOfView = self.view.bounds.width
        let yOfView = self.view.bounds.height
        let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
        menuView.frame = rect
        // menuView is hidden in viewDidLoad, now it is displayed
        self.menuView.isHidden = false
        self.showMenu = false
        
    }
    
    func hideMenu() {
        menuView.isHidden = true
        showMenu = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        cameraButton.isHidden = true
        photosButton.isHidden = true
        menuView.isHidden = true
        // UIImagePickerController's delegate object is of type UIImagePickerControllerDelegate and UINavigationControllerDelegate
        // a delegate of an object (e.g UITableViewDelegate) is a "protocol" that allows the object (UITableView) to be manipulated by calling functions with the object as an arguments. These functions or methods on the object can now be called anywhere within the delegate (self or settingsVC in this case)
        image.delegate = self
        editStory.delegate = self
        let firstName = user.object(forKey: "first_name") as! String
        let lastName = user.object(forKey: "last_name") as! String
        userName.text = firstName + " " + lastName
        // if story already exists for user, convert it to string (if possible- no "!" in typecast) and display it
        if let story = user.object(forKey: "story") {
            userStory.text = String(describing: story)
            userStory.sizeToFit()
            
        }
        // display user's saved image. user image data always exists in Parse
        let imageFile = user.object(forKey: "image") as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                self.userImage.image = UIImage(data: imageData as Data)
            
            }
        }
        let geopoint = user.object(forKey: "location") as! PFGeoPoint
        let lat = geopoint.latitude
        let long = geopoint.longitude
        let location = CLLocation(latitude: lat, longitude: long)
        // use function to get user's physical location from saved PFGeoPoint coordinates
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                if let city = placemark.locality {
                    if let countryCode = placemark.isoCountryCode {
                        self.userLocation.text = String(city) + ", " + String(countryCode)
                        
                    }
                }
            }
        })
    }
    
    // hide menuView on viewDidAppear so if user presses back to return to thois view, menuView is hidden. showMenu prevents the need for a double tap before menuView can be displayed again
    override func viewDidAppear(_ animated: Bool) {
        hideMenu()
        
    }
    
    // viewDidLayoutSubviews() runs each time layout changes
    override func viewDidLayoutSubviews() {
        hidePhotoBar()
        if UIDevice.current.orientation.isLandscape {
            // resize menuView (if present in view i.e if menuView is already being displayed) whenever orientation changes. this calculates the variable "rect" based on the new bounds
            for view in self.view.subviews {
                if view.tag == 2 {
                    let xOfView = self.view.bounds.width
                    let yOfView = self.view.bounds.height
                    let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
                    menuView.frame = rect
                    
                }
            }
        } else {
            // resize menuView in portrait
            for view in self.view.subviews {
                if view.tag == 2 {
                    let xOfView = self.view.bounds.width
                    let yOfView = self.view.bounds.height
                    let rect = CGRect(x: 0, y: 0.1*yOfView, width: 0.75*xOfView, height: 0.9*yOfView)
                    menuView.frame = rect
                    
                }
            }
        }
    }


    @IBAction func changePhoto(_ sender: Any) {
        if changingPhoto {
            showPhotoBar()
            
        } else {
           hidePhotoBar()
            
        }
    }

    @IBAction func photos(_ sender: Any) {
        // lets UIImagePickerController object know where to pick image from
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
        
    }
    
    @IBAction func camera(_ sender: Any) {
        image.sourceType = UIImagePickerControllerSourceType.camera
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
    }
    
    // called on editing did begin
    @IBAction func beginEdit(_ sender: Any) {
        scrollView.contentInset.bottom += CGFloat(300)
        if let story = user.object(forKey: "story") {
            editStory.text = String(describing: story)
            
        }
    }
    
    @IBAction func endEditing(_ sender: Any) {
        scrollView.contentInset.bottom -= CGFloat(300)
        
    }
    
    // edit action executes "after editing ends" or return button is tapped
    @IBAction func edit(_ sender: AnyObject) {
        runEdit()
        
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        if showMenu {
            displayMenu()

        } else {
            hideMenu()
            
        }
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
        // dismiss imagePicker controller
        self.dismiss(animated: true, completion: nil)
        hidePhotoBar()
        
    }

    // tap anywhere to escape keyboard. showMenu prevents the need for a double tap before menuView can be displayed again
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        hideMenu()
        
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        runEdit()
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
