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
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var usernameTextbox: UITextField!
    
    @IBOutlet weak var passwordTextbox: UITextField!
    
    @IBOutlet weak var phoneTextbox: UITextField!
    
    @IBAction func loginButton(sender: AnyObject) {
        var username = usernameTextbox.text
        let password = passwordTextbox.text
        
        if (username!.isEmpty) || (username!.isEmpty) {
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        } else {
            let loginController = Login()
            loginController.login(username!, password: password!)
            if (loginController.responso == "400") {
                displayAlert("Login Error", message: "Please check your login information.")
            }else {
                self.performSegueWithIdentifier("loginRider", sender: self)
            }

        }
    }
    
    
    @IBAction func registerButton(sender: AnyObject) {
        let email = usernameTextbox.text
        let password = passwordTextbox.text
        let phone = phoneTextbox.text
        
        if (email!.isEmpty) || (password!.isEmpty) {
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        } else {
            let registerController = Register()

            registerController.register(email!, password: password!,phone: phone! )
//            if (registerController.responso == "400") {
//
//                displayAlert("Login Error", message: "Please check your login information.")
//            }else {
//                self.performSegueWithIdentifier("loginRider", sender: self)
//            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.usernameTextbox.delegate = self;
        self.passwordTextbox.delegate = self;
    }
    
    //    override func viewDidAppear(animated: Bool) {
    //        // TODO: check if user if logged in, if so, performSegue
    //         self.performSegueWithIdentifier("loginRider", sender: self)
    //    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
}

