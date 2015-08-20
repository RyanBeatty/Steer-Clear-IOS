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
                                    
                                    // can't make UI updates from background thread, so we need to dispatch
                                    // them to the main thread
                                    dispatch_async(dispatch_get_main_queue(), {
                                        
                                        // check if registration succeeds
                                        if(!success) {
                                            // if it failed, display error
                                            self.displayAlert("Login Error", message: message)
                                        } else {
                                            // if it succeeded, log user in and change screens to
                                            self.performSegueWithIdentifier("loginRider", sender: self)
                                        }
                                    })
                            })
                        }
                })
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    /* Handles user alerts. For example, when Username or Password is required but not entered.
    */
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
