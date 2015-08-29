//
//  RegisterController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 8/11/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit

class RegisterController: UIViewController, UITextFieldDelegate {

    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    /*
    registerButton
    --------------
    Attempts to register user. On success, logs user in and redirects user to MapViewController and remembers username for next login.
    
    Helper: SCNetwork.register, login
    
    */
    @IBAction func registerButton(sender: AnyObject) {
        // get username, password, and phone
        let username = emailTextField.text
        let password = passwordTextField.text
        let phone = phoneTextField.text
        
        // check if form fields are emtpy
        if (username!.isEmpty) || (password!.isEmpty || (phone!.isEmpty)) {
            displayAlert("Missing Fields(s)", message: "Email, Password, and Phone Required")
        } else {
            
            // attempt to register user
            SCNetwork.register(
                username,
                password: password,
                phone: phone,
                completionHandler: {
                success, message in
                    
                    // can't make UI updates from background thread, so we need to dispatch
                    // them to the main thread
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        // check if registration succeeds
                        if(!success) {
                            // if it failed, display error
                            self.displayAlert("Registration Error", message: message)
                        } else {
                            // if it succeeded, log user in and change screens to
                            println("Logging in")
                            SCNetwork.login(
                                username,
                                password: password,
                                completionHandler: {
                                    success, message in
                                    
                                    if(!success) {
                                        //can't make UI updates from background thread, so we need to dispatch
                                        // them to the main thread
                                        dispatch_async(dispatch_get_main_queue(), {
                                            // login failed, display alert
                                            self.displayAlert("Login Error", message: message)
                                        })
                                    }
                                    else {
                                        //can't make UI updates from background thread, so we need to dispatch
                                        // them to the main thread
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.defaults.setObject("\(username)", forKey: "lastUser")                                    
                                            self.performSegueWithIdentifier("loginFromRegister", sender: self)
                                        })
                                    }
                            })
                        }
                    })
                }
            )
        }
    }
    
    /*
    login
    -----
    Helper Method to log user in.
    
    */
    func login(username: String, password: String) {
        SCNetwork.login(
            username,
            password: password,
            completionHandler: {
                success, message in
                
                // can't make UI updates from background thread, so we need to dispatch
                // them to the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // check if registration succeeds
                    if(!success) {
                        // if it failed, display error
                        self.displayAlert("Login Error", message: message)
                    } else {
                        // if it succeeded, log user in and change screens to
                        self.performSegueWithIdentifier("loginFromRegister", sender: self)
                    }
                })
        })
        
        
    }
    
    /*
    backButton
    ----------
    Returns user to login (ViewController).
    
    */
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("backToLoginSegue", sender: self)
    }
    
    /*
    displayAlert
    ------------
    Handles user alerts. For example, when Username or Password is required but not entered.
    
    */
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    /*
    DismissKeyboard
    ---------------
    When keyboard is enabled, will hide keyboard if outside tap recognized.
    
    */
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /*
    design
    ------
    Implements the following styles to the username and password textboxes in the Storyboard ViewController:
    
    UsernameTextbox: solid bottom border with customColor, change placeholder text white
    PasswordTextbox: solid bottom border with customColor, change placeholder text white
    
    EmailLabel: Apply font awesome icon
    PasswordLabel: Apply font awesome icon
    
    */
    func design() {
        // Colors
        let customColor = UIColor(hue: 0.1056, saturation: 0.5, brightness: 0.72, alpha: 0.5) /* #b9975b */
        
        
        // Username text box
        emailTextField.layer.masksToBounds = true
        self.emailTextField.attributedPlaceholder = NSAttributedString(string:self.emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        
        // Phone text box
        self.phoneTextField.attributedPlaceholder = NSAttributedString(string:self.phoneTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])

        
        // Password text box
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string:self.passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
