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
    
    var networkController = Network()
    
    
    @IBAction func loginButton(sender: AnyObject) {
        var email = usernameTextbox.text
        let password = passwordTextbox.text
        
        if (email!.isEmpty) || (password!.isEmpty) {
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        }
        else {
            networkController.login(email!, password: password!)
            self.performSegueWithIdentifier("loginRider", sender: self)
        }
    }
    
    
    @IBAction func registerButton(sender: AnyObject) {
        let email = usernameTextbox.text
        let password = passwordTextbox.text
        let phone = phoneTextbox.text
        var response = 2
        if (email!.isEmpty) || (password!.isEmpty) {
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        } else {
            networkController.register(email!, password: password!, phone: phone!)
            while (networkController.responseFound != true){
                print("waiting for server response")
                usleep(1000)
            }
            response = networkController.responseStatus
            print("now we can check response = \(response)")
            if (response == 400) {
                displayAlert("Registration Error", message: "Invalid Registration")
                networkController.responseFound = false
            }
            else if (response == 409) {
                displayAlert("Registration Error", message: "You have already registered!")
                networkController.responseFound = false
            } else {
                networkController.login(email!, password: password!)
                self.performSegueWithIdentifier("loginRider", sender: self)
            }
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

