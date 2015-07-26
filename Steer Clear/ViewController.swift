//
//  ViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 5/15/15.
//  Copyright (c) 2015 Paradoxium. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextFieldDelegate {
    
    func displayAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var usernameTextbox: UITextField!
    
    @IBOutlet weak var passwordTextbox: UITextField!
    
    @IBAction func loginButton(sender: AnyObject) {
        var username = usernameTextbox.text
        var password = passwordTextbox.text
        
        if (username.isEmpty) || (username.isEmpty) {
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        } else {
            let loginController = Login()
            loginController.login(username, password: password)
        }
    }
    
    
    @IBAction func registerButton(sender: AnyObject) {
        var username = usernameTextbox.text
        var password = passwordTextbox.text
        
        if (username.isEmpty) || (username.isEmpty) {
            displayAlert("Missing Fields(s)", message: "Username and Password Required")
        } else {
            let loginController = Register()
            loginController.register(username, password: password)
        }
    }
    
    @IBAction func addRide(sender: AnyObject) {
        let addRideController = AddRide()
        addRideController.sendRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.usernameTextbox.delegate = self;
        self.passwordTextbox.delegate = self;
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
}

