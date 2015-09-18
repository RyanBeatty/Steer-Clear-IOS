//
//  NavigationController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 9/7/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidAppear(animated: Bool) {
        
        let data: NSData? = defaults.objectForKey("sessionCookies") as? NSData
        if let cookie = data {
            let datas: NSArray? = NSKeyedUnarchiver.unarchiveObjectWithData(cookie) as? NSArray
            if let cookies = datas {
                for c in cookies as! [NSHTTPCookie] {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(c)
                }
            }
        }
        
        
        if cookiesPresent() {
            if pickupPresent() {
                // check whether ride has already been deleted
                self.performSegueWithIdentifier("waitingViewController", sender: self)
            }
            else {
                self.performSegueWithIdentifier("mapViewController", sender: self)
            }
        } else {
            self.performSegueWithIdentifier("viewController", sender: self)
        }

        
    }
    
    
    func pickupPresent()->Bool{
        let pickupTime: AnyObject? = defaults.objectForKey("pickupTime")
        if (pickupTime == nil){
            print("No pickup time")
            return false
        }
        else {
            return true
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
    
}