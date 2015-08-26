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
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = customColor.CGColor
        border.frame = CGRect(x: 0, y: emailTextField.frame.size.height - width, width:  emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        border.borderWidth = width
        emailTextField.layer.addSublayer(border)
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 25, self.emailTextField.frame.height))
        emailTextField.leftView = paddingView
        emailTextField.leftViewMode = UITextFieldViewMode.Always
        
        // Phone text box
        self.phoneTextField.attributedPlaceholder = NSAttributedString(string:self.phoneTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        let border2 = CALayer()
        let width2 = CGFloat(2.0)
        border2.borderColor = customColor.CGColor
        border2.frame = CGRect(x: 0, y: phoneTextField.frame.size.height - width2, width:  phoneTextField.frame.size.width, height: phoneTextField.frame.size.height)
        border2.borderWidth = width2
        phoneTextField.layer.addSublayer(border2)
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 25, self.phoneTextField.frame.height))
        phoneTextField.leftView = paddingView2
        phoneTextField.leftViewMode = UITextFieldViewMode.Always
        
        // Password text box
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string:self.passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        let border3 = CALayer()
        let width3  = CGFloat(2.0)
        border3.borderColor = customColor.CGColor
        border3.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width3, width:  passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        border3.borderWidth = width3
        passwordTextField.layer.addSublayer(border3)
        let paddingView3 = UIView(frame: CGRectMake(0, 0, 25, self.passwordTextField.frame.height))
        passwordTextField.leftView = paddingView3
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        
        // Phone Font Awesome Icon
        phoneLabel.font = UIFont(name: "FontAwesome", size: 20)
        phoneLabel.text = String(format: "%C", 0xf018)
        phoneLabel.textColor = UIColor.blackColor()
        
        // Username Font Awesome Icon
        usernameLabel.font = UIFont(name: "FontAwesome", size: 20)
        usernameLabel.text = String(format: "%C", 0xf003)
        usernameLabel.textColor = UIColor.blackColor()
        
        // Password Font Awesome Icon
        passwordLabel.font = UIFont(name: "FontAwesome", size: 20)
        passwordLabel.text = String(format: "%C", 0xf023)
        passwordLabel.textColor = UIColor.blackColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
