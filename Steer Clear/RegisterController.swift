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
    var networkController = Network()
    
    @IBAction func registerButton(sender: AnyObject) {
                var email = emailTextField.text
                let password = passwordTextField.text
                let phone = phoneTextField.text
                var response = 2
                if (email!.isEmpty) || (password!.isEmpty) {
                    displayAlert("Missing Fields(s)", message: "Email and Password Required")
                } else {
                    networkController.register(email!, password: password!, phone: phone!)
                    while (networkController.responseFound != true){
                        print("waiting for server response")
                        usleep(5000)
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
                    } else if (response == 200){
                        networkController.login(email!, password: password!)
                        self.performSegueWithIdentifier("loginFromRegister", sender: self)
                    } else {
                         displayAlert("Unsucessful Registration", message: "Please try again later.")
                    }
                }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("segue loaded")
        // Do any additional setup after loading the view.
    }
    
    /* Handles user alerts. For example, when Username or Password is required but not entered.
    */
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
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
