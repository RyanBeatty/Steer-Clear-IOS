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
    @IBOutlet weak var phoneUnderlineLabel: UIView!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createAnAccountLabel: UIButton!
    
    @IBOutlet weak var logo: UIImageView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var isRotating = false
    var shouldStopRotating = false
    var offset: CGFloat = 500
    
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
    
    override func viewDidAppear(animated: Bool) {

        let startXphoneTextBox = self.phoneTextbox.frame.origin.x
        let startXphonelabel = self.phoneLabel.frame.origin.x
        let startXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
        
        self.phoneTextbox.frame.origin.x = startXphoneTextBox - self.offset
        self.phoneLabel.frame.origin.x = startXphonelabel - self.offset
        self.phoneUnderlineLabel.frame.origin.x = startXphoneUnderline - self.offset
        
        phoneTextbox.hidden = true
        phoneLabel.hidden = true
        phoneUnderlineLabel.hidden = true
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
        var phone = phoneTextbox.text
        let startX = self.loginBtn.frame.origin.x
        if (username!.isEmpty) || (password!.isEmpty) {
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
            self.displayAlert("Form Error", message: "Please make sure you have filled all fields.")
        } else {
            if loginBtn.titleLabel?.text == "LOGIN" {
                if self.isRotating == false {
                    self.logo.rotate360Degrees(completionDelegate: self)
                    // Perhaps start a process which will refresh the UI...
                    self.shouldStopRotating = true
                    self.isRotating = true
                }
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
                                self.displayAlert("Login Error", message: message)
                                self.shouldStopRotating = true
                            })
                        }
                        else {
                            // can't make UI updates from background thread, so we need to dispatch
                            // them to the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                self.shouldStopRotating = true
                                self.phoneTextbox.hidden = true
                                self.phoneLabel.hidden = true
                                self.phoneUnderlineLabel.hidden = true
                                
                                self.defaults.setObject("\(username)", forKey: "lastUser")
                                self.performSegueWithIdentifier("loginRider", sender: self)
                            })
                        }
                })
            }
            else {
                //lets register
                if (phone!.isEmpty) {
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
                    self.displayAlert("Form Error", message: "Please make sure you have filled all fields.")
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
                                                self.performSegueWithIdentifier("loginRider", sender: self)
                                            })
                                        }
                                })
                            }
                        })
                    }
                )
            }
            
        }
        }
        
    }
        
       
    /*
    registerButton
    --------------
    Redirects user to Registration Page
    
    */
    @IBAction func registerButton(sender: AnyObject) {
        let customColor = UIColor(hue: 0.4444, saturation: 0.8, brightness: 0.34, alpha: 1.0) /* #115740 */
        let startXphoneTextBox = self.phoneTextbox.frame.origin.x
        let startXphonelabel = self.phoneLabel.frame.origin.x
        let startXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
        
        if createAnAccountLabel.titleLabel!.text == "Don't have an account? REGISTER" {
            
            phoneTextbox.hidden = false
            phoneLabel.hidden = false
            phoneUnderlineLabel.hidden = false
            
            UIView.animateWithDuration(
                0.5,
                animations: {
                    self.phoneTextbox.frame.origin.x = startXphoneTextBox + self.offset
                    self.phoneLabel.frame.origin.x = startXphonelabel + self.offset
                    self.phoneUnderlineLabel.frame.origin.x = startXphoneUnderline + self.offset
                },
                completion: nil
            )
            
            createAnAccountLabel.setTitle("Cancel", forState: UIControlState.Normal)
            loginBtn.setTitle("REGISTER", forState: UIControlState.Normal)
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME (treveley)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            loginBtn.backgroundColor = UIColor.whiteColor()
            loginBtn.setTitleColor(customColor , forState: UIControlState.Normal)
        }
        else {
            
            UIView.animateWithDuration(
                0.5,
                animations: {
                    self.phoneTextbox.frame.origin.x = startXphoneTextBox - self.offset
                    self.phoneLabel.frame.origin.x = startXphonelabel - self.offset
                    self.phoneUnderlineLabel.frame.origin.x = startXphoneUnderline - self.offset
                },
                completion: { finish in
                    UIView.animateWithDuration(
                        0.1,
                        animations: {
                            self.phoneTextbox.frame.origin.x = startXphoneTextBox - self.offset
                            self.phoneLabel.frame.origin.x = startXphonelabel - self.offset
                            self.phoneUnderlineLabel.frame.origin.x = startXphoneUnderline - self.offset
                        }
                    )
                }
            )
            
            createAnAccountLabel.setTitle("Don't have an account? REGISTER", forState: UIControlState.Normal)
            loginBtn.setTitle("LOGIN", forState: UIControlState.Normal)
            
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            loginBtn.backgroundColor = UIColor.clearColor()
            loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
       
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
        
        self.phoneTextbox.attributedPlaceholder = NSAttributedString(string:self.phoneTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    func checkUser() {
        let customColor = UIColor(hue: 0.4444, saturation: 0.8, brightness: 0.34, alpha: 1.0) /* #115740 */
        let startXphoneTextBox = self.phoneTextbox.frame.origin.x
        let startXphonelabel = self.phoneLabel.frame.origin.x
        let startXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
        
        if isAppAlreadyLaunchedOnce() == false {
            phoneTextbox.hidden = false
            phoneLabel.hidden = false
            phoneUnderlineLabel.hidden = false
            
                    self.phoneTextbox.frame.origin.x = startXphoneTextBox + self.offset
                    self.phoneLabel.frame.origin.x = startXphonelabel + self.offset
                    self.phoneUnderlineLabel.frame.origin.x = startXphoneUnderline + self.offset
            
            createAnAccountLabel.setTitle("Cancel", forState: UIControlState.Normal)
            loginBtn.setTitle("REGISTER", forState: UIControlState.Normal)
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME (treveley)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            loginBtn.backgroundColor = UIColor.whiteColor()
            loginBtn.setTitleColor(customColor , forState: UIControlState.Normal)
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
    
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.logo.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
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

