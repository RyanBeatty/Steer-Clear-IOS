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
    
    var networkController = Network()
    var userLoggedIn = true
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidAppear(animated: Bool) {
        checkUser()
    }
    
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

    /*
    loginButton
    -----------
    Attempts to login user. On success, redirects user to MapViewController and remembers username
    for next login.

    Helper: SCNetwork.login
    
    */
    @IBAction func loginButton(sender: AnyObject) {
        var username = usernameTextbox.text
        let password = passwordTextbox.text
        
        if (username!.isEmpty) || (password!.isEmpty) {
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        } else {
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
                            self.defaults.setObject("\(username)", forKey: "lastUser")
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        }
                    })
                }
            )
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
        let customColor = UIColor(hue: 0.1056, saturation: 0.5, brightness: 0.72, alpha: 1.0) /* #b9975b */
        

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
        
        // Email Font Awesome Icon
        emailLabel.font = UIFont(name: "FontAwesome", size: 20)
        emailLabel.text = String(format: "%C", 0xf003)
        emailLabel.textColor = customColor
        
        // Password Font Awesome Icon
        passwordLabel.font = UIFont(name: "FontAwesome", size: 20)
        passwordLabel.text = String(format: "%C", 0xf023)
        passwordLabel.textColor = customColor
        
    }
    
    /*
    checkUser
    --------
    If first time opening app, redirects to RegisterController. Checks if user is already logged in.
    If so, will redirect to MapViewController.
    
    */
    func checkUser() {
        if !isAppAlreadyLaunchedOnce() {
            println("new user redirecting to register page")
            self.performSegueWithIdentifier("registerSegue", sender: self)
        } else {
            println("not new user lets see if logged in")
            // TODO unhardcode this
            if SCNetwork.isUserLoggedIn() {
                println("User logged in lets go to maps")
               // self.performSegueWithIdentifier("loginRider", sender: self)
            } else {
                println("lets display login screen")
            }
        }
        
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
    isAppAlreadyLaunchedOnce
    ------------------------
    Checks if app has already been launched, returns true if it has.
    
    */
    func isAppAlreadyLaunchedOnce()->Bool{
        if let isAppAlreadyLaunchedOnce = self.defaults.stringForKey("isAppAlreadyLaunchedOnce"){
            println("App already launched")
            return true
        } else {
            defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            println("App launched first time")
            return false
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

