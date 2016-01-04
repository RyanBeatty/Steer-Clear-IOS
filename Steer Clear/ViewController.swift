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
    
    @IBOutlet weak var usernameIcon: UILabel!
    @IBOutlet weak var passwordIcon: UILabel!
    @IBOutlet weak var phoneIcon: UILabel!
    
    @IBOutlet weak var usernameUnderlineLabel: UIView!
    @IBOutlet weak var phoneUnderlineLabel: UIView!
    @IBOutlet weak var passwordUnderlineLabel: UIView!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createAnAccountLabel: UIButton!
    
    @IBOutlet weak var steerClearLogo: UIImageView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var isRotating = false
    var shouldStopRotating = false
    var offset: CGFloat = 500
    var myString:NSString = "Don't have an account? REGISTER"
    var cancelNSString:NSString = "Cancel"
    var cancelMutableString = NSMutableAttributedString()
    var registerMutableString = NSMutableAttributedString()
    
    var startX = CGFloat()
    var startXphoneTextBox = CGFloat()
    var startXphonelabel = CGFloat()
    var startXphoneUnderline = CGFloat()
    var endXphoneTextBox = CGFloat()
    var endXphonelabel = CGFloat()
    var endXphoneUnderline = CGFloat()
    var keyboardUp = false
    
    var settings = Settings()
    
    override func viewDidLoad() {
        
        print("----------------------------------------------------------------------------------------")
        print("ViewController: Initializing ViewController")
        super.viewDidLoad()
        design()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.usernameTextbox.delegate = self;
        self.passwordTextbox.delegate = self;
        if self.defaults.stringForKey("lastUser") != nil {
            self.usernameTextbox.text = self.defaults.stringForKey("lastUser")!
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let name = "ViewController"
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        hidePhoneLabels()
    }
    
    override func viewDidAppear(animated: Bool) {
        getPhoneLabelsLocation()
        movePhoneLabelsOffScreen(false)
        
        self.startX = self.loginBtn.frame.origin.x
        
        checkUser()
        
        usernameTextbox.delegate = self
        passwordTextbox.delegate = self
        self.usernameTextbox.nextField = self.passwordTextbox
        
    }
    
    /*
    loginButton
    -----------
    Attempts to log the user into the system
    */
    @IBAction func login(sender: AnyObject) {
        // grab username and password fields and check if they are not null
        print("ViewController: Attempting to login...")
        let username = usernameTextbox.text
        let password = passwordTextbox.text
        let phone = phoneTextbox.text
        if (username!.isEmpty) || (password!.isEmpty) {
            print("ViewController: Not all fields are filled.")
            jiggleLogin()
            self.displayAlert("Form Error", message: "Please make sure you have filled all fields.")
        } else {
            print("ViewController: Sending LOGIN network request.")
            if loginBtn.titleLabel?.text == "LOGIN" {
                if self.isRotating == false {
                    self.steerClearLogo.rotate360Degrees(completionDelegate: self)
                    // Perhaps start a process which will refresh the UI...
                }
                // else try to log the user in
                SCNetwork.login(
                    username!,
                    password: password!,
                    completionHandler: {
                        success, message in
                        
                        if(!success) {
                            // can't make UI updates from background thread, so we need to dispatch
                            // them to the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                print("ViewController: Login failed ~ \(message)")
                                self.jiggleLogin()
                                self.displayAlert("Login Error", message: message)
                                self.shouldStopRotating = true
                                
                            })
                        }
                        else {
                            // can't make UI updates from background thread, so we need to dispatch
                            // them to the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                print("ViewController: Login successful, seguing towards MapViewController.")
                                self.shouldStopRotating = true
                                self.phoneTextbox.hidden = true
                                self.phoneLabel.hidden = true
                                self.phoneUnderlineLabel.hidden = true
                                
                                let cookies: NSArray = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as NSArray!
                                
                                Cookies.setCookiesWithArr(cookies)
                                
                                self.defaults.setObject("\(username!)", forKey: "lastUser")
                                self.performSegueWithIdentifier("loginRider", sender: self)
                            })
                        }
                })
            }
            else {
                print("ViewController: Attempting to register...")
                if (phone!.isEmpty) {
                    print("ViewController: Not all fields are filled.")
                    jiggleLogin()
                    self.displayAlert("Form Error", message: "Please make sure you have filled all fields.")
                } else {
                    print("ViewController: Sending register network request.")
                    SCNetwork.register(
                        username!,
                        password: password!,
                        phone: phone!,
                        completionHandler: {
                            success, message in
                            
                            // can't make UI updates from background thread, so we need to dispatch
                            // them to the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                // check if registration succeeds
                                if(!success) {
                                    print("ViewController: Registration Error ~ \(message)")
                                    self.displayAlert("Registration Error", message: message)
                                } else {
                                    // if it succeeded, log user in and change screens to
                                    print("ViewController: Sending LOGIN network request.")
                                    SCNetwork.login(
                                        username!,
                                        password: password!,
                                        completionHandler: {
                                            success, message in
                                            
                                            if(!success) {
                                                //can't make UI updates from background thread, so we need to dispatch
                                                // them to the main thread
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    print("ViewController: Login failed ~ \(message)")
                                                    self.displayAlert("Login Error", message: message)
                                                })
                                            }
                                            else {
                                                //can't make UI updates from background thread, so we need to dispatch
                                                // them to the main thread
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    print("ViewController: Login successful, seguing towards MapViewController.")
                                                    let cookies: NSArray = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as NSArray!
                                                    
                                                    Cookies.setCookiesWithArr(cookies)
                                                    
                                                    self.defaults.setObject("\(username!)", forKey: "lastUser")
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
        
        if createAnAccountLabel.titleLabel!.text == "Don't have an account? REGISTER" {
            print("ViewController: User pressed Registration button, updating UI to show phone label.")
            unHidePhoneLabels()
            movePhoneLabelsOnScreen()
            
            createAnAccountLabel.setAttributedTitle(self.cancelMutableString, forState: UIControlState.Normal)
            loginBtn.setTitle("REGISTER", forState: UIControlState.Normal)
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME (treveley)", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
            loginBtn.backgroundColor = UIColor.whiteColor()
            loginBtn.setTitleColor(settings.wmGreen , forState: UIControlState.Normal)
        }
        else {
            print("ViewController: User pressed Registration button, updating UI to hide phone label.")
            movePhoneLabelsOffScreen(true)
            
            createAnAccountLabel.setAttributedTitle(registerMutableString, forState: UIControlState.Normal)
            loginBtn.setTitle("LOGIN", forState: UIControlState.Normal)
            
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
            
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
        self.loginBtn.layer.borderWidth = 2
        self.loginBtn.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Username text box
        usernameTextbox.layer.masksToBounds = true
        self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:self.usernameTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        
        // Password text box
        self.passwordTextbox.attributedPlaceholder = NSAttributedString(string:self.passwordTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        
        self.phoneTextbox.attributedPlaceholder = NSAttributedString(string:self.phoneTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        
        
        
        cancelMutableString = NSMutableAttributedString(string: cancelNSString as String, attributes: [NSFontAttributeName:UIFont(name: "Avenir Next", size: 15.0)!])
        
        registerMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Avenir Next", size: 15.0)!])
        
        registerMutableString.addAttribute(NSForegroundColorAttributeName, value: settings.spiritGold, range: NSRange(location:23,length:8))
        
        createAnAccountLabel.setAttributedTitle(registerMutableString, forState: UIControlState.Normal)
        
    }
    
    func checkUser() {
        if isAppAlreadyLaunchedOnce() == false {
            phoneTextbox.hidden = false
            phoneLabel.hidden = false
            phoneUnderlineLabel.hidden = false
            
            self.phoneTextbox.frame.origin.x = self.startXphoneTextBox
            self.phoneTextbox.frame.origin.x = self.startXphoneTextBox
            self.phoneLabel.frame.origin.x = self.startXphonelabel
            self.phoneUnderlineLabel.frame.origin.x = self.startXphoneUnderline
            
            createAnAccountLabel.setAttributedTitle(self.cancelMutableString, forState: UIControlState.Normal)
            loginBtn.setTitle("REGISTER", forState: UIControlState.Normal)
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME (treveley)", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
            print("bringing back to center")
            loginBtn.backgroundColor = UIColor.whiteColor()
            loginBtn.setTitleColor(settings.wmGreen , forState: UIControlState.Normal)
        }
    }
    
    func cookiesPresent()->Bool{
        let data: NSData? = defaults.objectForKey("sessionCookies") as? NSData
        if (data == nil){
            print("No cookies, let user log in")
            return false
        }
        else {
            return true
        }
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        if let _ = self.defaults.stringForKey("isAppAlreadyLaunchedOnce"){
            return true
        }
        else {
            defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            print("ViewController: First time launching app, displaying registration screen.")
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
    
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.steerClearLogo.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let nextField = textField.nextField {
            nextField.becomeFirstResponder()
        }
        if (textField.returnKeyType==UIReturnKeyType.Go)
        {
            textField.resignFirstResponder() // Dismiss the keyboard
            loginBtn.sendActionsForControlEvents(.TouchUpInside)
        }
        return true
    }
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func jiggleLogin() {
        UIView.animateWithDuration(
            0.1,
            animations: {
                self.loginBtn.frame.origin.x = self.startX - 10
            },
            completion: { finish in
                UIView.animateWithDuration(
                    0.1,
                    animations: {
                        self.loginBtn.frame.origin.x = self.startX + 10
                    },
                    completion: { finish in
                        UIView.animateWithDuration(
                            0.1,
                            animations: {
                                self.loginBtn.frame.origin.x = self.startX
                            }
                        )
                    }
                )
            }
        )
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
    
    func keyboardWillShow(notification: NSNotification) {
        if (!self.keyboardUp) {
            
            if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                UIView.animateWithDuration(0.5, animations: {
                    self.steerClearLogo.alpha = 0.0
                    
                })
                
                self.usernameTextbox.frame.origin.y -= 100
                self.usernameIcon.frame.origin.y -= 100
                self.usernameUnderlineLabel.frame.origin.y -= 100
                
                self.passwordTextbox.frame.origin.y -= 100
                self.passwordIcon.frame.origin.y -= 100
                self.passwordUnderlineLabel.frame.origin.y -= 100
                
                self.phoneTextbox.frame.origin.y -= 100
                self.phoneIcon.frame.origin.y -= 100
                self.phoneUnderlineLabel.frame.origin.y -= 100
                
            }
            
            self.keyboardUp = true
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardUp {
            if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.usernameTextbox.frame.origin.y += 100
                self.usernameIcon.frame.origin.y += 100
                self.usernameUnderlineLabel.frame.origin.y += 100
                
                self.passwordTextbox.frame.origin.y += 100
                self.passwordIcon.frame.origin.y += 100
                self.passwordUnderlineLabel.frame.origin.y += 100
                
                self.phoneTextbox.frame.origin.y += 100
                self.phoneIcon.frame.origin.y += 100
                self.phoneUnderlineLabel.frame.origin.y += 100
                
                
                UIView.animateWithDuration(0.5, animations: {
                    self.steerClearLogo.alpha = 1.0
                    
                })
                self.keyboardUp = false
            }
            
        }
    }
    
    
    func hidePhoneLabels() {
        phoneTextbox.hidden = true
        phoneLabel.hidden = true
        phoneUnderlineLabel.hidden = true
        
    }
    
    func unHidePhoneLabels() {
        phoneTextbox.hidden = false
        phoneLabel.hidden = false
        phoneUnderlineLabel.hidden = false
    }
    
    func getPhoneLabelsLocation() {
        self.startXphoneTextBox = self.phoneTextbox.frame.origin.x
        self.startXphonelabel = self.phoneLabel.frame.origin.x
        self.startXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
        
    }
    
    func movePhoneLabelsOffScreen(animate: Bool) {
        if animate {
            UIView.animateWithDuration(
                0.5,
                animations: {
                    self.phoneTextbox.frame.origin.x = self.endXphoneTextBox
                    self.phoneLabel.frame.origin.x = self.endXphonelabel
                    self.phoneUnderlineLabel.frame.origin.x = self.endXphoneUnderline
                },
                completion: nil
            )
            
        }
        else {
            self.phoneTextbox.frame.origin.x = startXphoneTextBox - self.offset
            self.phoneLabel.frame.origin.x = startXphonelabel - self.offset
            self.phoneUnderlineLabel.frame.origin.x = startXphoneUnderline - self.offset
            
            self.endXphoneTextBox = self.phoneTextbox.frame.origin.x
            self.endXphonelabel = self.phoneLabel.frame.origin.x
            self.endXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
            
        }
    }
    
    func movePhoneLabelsOnScreen() {
        UIView.animateWithDuration(
            0.5,
            animations: {
                self.phoneTextbox.frame.origin.x = self.startXphoneTextBox
                self.phoneLabel.frame.origin.x = self.startXphonelabel
                self.phoneUnderlineLabel.frame.origin.x = self.startXphoneUnderline
            },
            completion: nil
        )
        
    }
    
    
    
    
}