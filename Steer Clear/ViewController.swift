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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
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
        var email = usernameTextbox.text
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
    
    func design() {
        // Colors
        let lightBlue = UIColor(hue: 0.6083, saturation: 0.35, brightness: 0.83, alpha: 1.0)
        

        
        // Email text box
        self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:self.usernameTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = lightBlue.CGColor
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
        border2.borderColor = lightBlue.CGColor
        border2.frame = CGRect(x: 0, y: passwordTextbox.frame.size.height - width2, width:  passwordTextbox.frame.size.width, height: passwordTextbox.frame.size.height)
        border2.borderWidth = width2
        passwordTextbox.layer.addSublayer(border2)
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 25, self.passwordTextbox.frame.height))
        passwordTextbox.leftView = paddingView2
        passwordTextbox.leftViewMode = UITextFieldViewMode.Always
        
        
        // Phone text box
        self.phoneTextbox.attributedPlaceholder = NSAttributedString(string:self.phoneTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        let border3 = CALayer()
        let width3 = CGFloat(2.0)
        border3.borderColor = lightBlue.CGColor
        border3.frame = CGRect(x: 0, y: phoneTextbox.frame.size.height - width3, width:  phoneTextbox.frame.size.width, height: passwordTextbox.frame.size.height)
        border3.borderWidth = width3
        phoneTextbox.layer.addSublayer(border3)
        let paddingView3 = UIView(frame: CGRectMake(0, 0, 25, self.phoneTextbox.frame.height))
        phoneTextbox.leftView = paddingView3
        phoneTextbox.leftViewMode = UITextFieldViewMode.Always
        
        
        
        // Email Font Awesome
        emailLabel.font = UIFont(name: "FontAwesome", size: 20)
        emailLabel.text = String(format: "%C", 0xf003)
        emailLabel.textColor = lightBlue
        
        // Password Font Awesome
        passwordLabel.font = UIFont(name: "FontAwesome", size: 20)
        passwordLabel.text = String(format: "%C", 0xf023)
        passwordLabel.textColor = lightBlue
        
        // Phone Font Awesome
        phoneLabel.font = UIFont(name: "FontAwesome", size: 30)
        phoneLabel.text = String(format: "%C", 0xf10b)
        phoneLabel.textColor = lightBlue
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        usernameTextbox.layer.masksToBounds = true
        
        design()
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

