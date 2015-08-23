//
//  ViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 5/15/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextbox: UITextField!
    @IBOutlet weak var passwordTextbox: UITextField!
    @IBOutlet weak var phoneTextbox: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.usernameTextbox.delegate = self;
        self.passwordTextbox.delegate = self;
        if self.defaults.stringForKey("lastUser") != nil {
            self.usernameTextbox.text = self.defaults.stringForKey("lastUser")
        }
    }
    
    // unwind segue method so that you can cancel registration view controller
    @IBAction func cancelToLoginViewController(segue:UIStoryboardSegue) {
        
    }

    /*
        loginButton
        -----------
        Attemts to log the user into the system
    */
    @IBAction func loginButton(sender: AnyObject) {
        let storeUserData = NSUserDefaults.standardUserDefaults()
        
        // grab username and password fields and check if they are not null
        var username = usernameTextbox.text
        var password = passwordTextbox.text
        
        if (username!.isEmpty) || (password!.isEmpty) {
            // alert user to fill in empty fields
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        }
        else {
            // else try to log the user in
            SCNetwork.login(
                username,
                password: password,
                completionHandler: {
                    success, message in
                    
                    if(!success) {
                        // can't make UI updates from background thread, so we need to dispatch
                        // them to the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            // login failed, display error
                            self.displayAlert("Login Error", message: message)
                        })
                    }
                    else {
                        // can't make UI updates from background thread, so we need to dispatch
                        // them to the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            // login succeeded, switch to mapview
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        })
                    }
            })
        }
    }
    
    /*
    registerButton
    --------------
    Redirects user to Registration Page
    
    */
    @IBAction func registerButton(sender: AnyObject) {
        // redirects to register page
        self.performSegueWithIdentifier("registerSegue", sender: self)
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
        usernameTextbox.layer.masksToBounds = true
        self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:self.usernameTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = customColor.CGColor
        border.frame = CGRect(x: 0, y: usernameTextbox.frame.size.height - width, width:  usernameTextbox.frame.size.width, height: usernameTextbox.frame.size.height)
        border.borderWidth = width
        usernameTextbox.layer.addSublayer(border)
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 25, self.usernameTextbox.frame.height))
        usernameTextbox.leftView = paddingView
        usernameTextbox.leftViewMode = UITextFieldViewMode.Always
        
        // Password text box
        self.passwordTextbox.attributedPlaceholder = NSAttributedString(string:self.passwordTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        let border2 = CALayer()
        let width2 = CGFloat(2.0)
        border2.borderColor = customColor.CGColor
        border2.frame = CGRect(x: 0, y: passwordTextbox.frame.size.height - width2, width:  passwordTextbox.frame.size.width, height: passwordTextbox.frame.size.height)
        border2.borderWidth = width2
        passwordTextbox.layer.addSublayer(border2)
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 25, self.passwordTextbox.frame.height))
        passwordTextbox.leftView = paddingView2
        passwordTextbox.leftViewMode = UITextFieldViewMode.Always
        
        // Email Font Awesome
        emailLabel.font = UIFont(name: "FontAwesome", size: 20)
        emailLabel.text = String(format: "%C", 0xf003)
        emailLabel.textColor = UIColor.whiteColor()
        
        // Password Font Awesome Icon
        passwordLabel.font = UIFont(name: "FontAwesome", size: 20)
        passwordLabel.text = String(format: "%C", 0xf023)
        passwordLabel.textColor = UIColor.whiteColor()
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
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

