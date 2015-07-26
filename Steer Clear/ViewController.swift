//
//  ViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 5/15/15.
//  Copyright (c) 2015 Paradoxium. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    
    @IBAction func registerButton(sender: AnyObject) {
        let registerController = Register()
        registerController.sendRequest()
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        let loginController = Login()
        loginController.sendRequest()
    }
    
    @IBAction func hailARideButton(sender: AnyObject) {
        let addRideController = AddRide()
        addRideController.sendRequest()
    }

    @IBAction func clearButton(sender: AnyObject) {
        let clearController = ClearQueue()
        clearController.sendRequest()
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        let logoutController = Logout()
        logoutController.sendRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

