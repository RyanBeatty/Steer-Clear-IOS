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
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var logo: UIImageView!
    
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
        
//        let numberToolbar = UIToolbar(frame: CGRectMake(0,0,320,50))
//        numberToolbar.barStyle = UIBarStyle.Default
//        
//        numberToolbar.items = [
//            UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: "keyboardCancelButtonTapped:"),
//            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "keyboardDoneButtonTapped:")]
//        
//        numberToolbar.sizeToFit()
//        usernameTextbox.inputAccessoryView = numberToolbar
    }
    
    override func viewDidAppear(animated: Bool) {
        checkUser()
    }
    
    // unwind segue method so that you can cancel registration view controller
    @IBAction func cancelToLoginViewController(segue:UIStoryboardSegue) {
        
    }

    /*
        loginButton
        -----------
        Attempts to log the user into the system
    */
    @IBAction func login(sender: AnyObject) {
        // grab username and password fields and check if they are not null
        
        var username = usernameTextbox.text
        var password = passwordTextbox.text
        
        if (username!.isEmpty) || (password!.isEmpty) {
            let startX = self.loginBtn.frame.origin.x
            UIView.animateWithDuration(
                0.1,
                animations: {
                    self.loginBtn.frame.origin.x = startX - 10
                },
                completion: { finish in
                    UIView.animateWithDuration(
                        0.1,
                        animations: {
                            self.loginBtn.frame.origin.x = startX + 10
                        },
                        completion: { finish in
                            UIView.animateWithDuration(
                                0.1,
                                animations: {
                                    self.loginBtn.frame.origin.x = startX
                                }
                            )
                        }
                    )
                }
            )
        self.displayAlert("Form Error", message: "Please enter your username and password.")
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
                            self.defaults.setObject("\(username)", forKey: "lastUser")
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
    
        UsernameTextbox: change placeholder text white
        PasswordTextbox: change placeholder text white
    
    */
    func design() {
        // Colors
        let customColor = UIColor(hue: 0.1056, saturation: 0.5, brightness: 0.72, alpha: 0.5) /* #b9975b */
        self.loginBtn.layer.borderWidth = 2
        self.loginBtn.layer.borderColor = UIColor.whiteColor().CGColor

        // Username text box
        usernameTextbox.layer.masksToBounds = true
        self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:self.usernameTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Password text box
        self.passwordTextbox.attributedPlaceholder = NSAttributedString(string:self.passwordTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    func checkUser() {
        if isAppAlreadyLaunchedOnce() == false {
            println("new user redirecting to register page")
            self.performSegueWithIdentifier("registerSegue", sender: self)
        }
        else {
            println("not new user lets see if logged in")
            SCNetwork.checkIndex(
                {
                    success, message in
                    
                    if(!success) {
                        // can't make UI updates from background thread, so we need to dispatch
                        // them to the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            println("User not logged in, let user log in.")
                            
                        })
                    }
                    else {
                        // can't make UI updates from background thread, so we need to dispatch
                        // them to the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        })
                    }
            })
        }
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        if let isAppAlreadyLaunchedOnce = self.defaults.stringForKey("isAppAlreadyLaunchedOnce"){
            println("App already launched")
            return true
        }
        else {
            defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            println("App launched first time")
            return false
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

