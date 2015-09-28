//
//  NavigationController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 9/7/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class NavigationController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidAppear(animated: Bool) {
        print("NavigationController: Initializing App!")
        
        print("NavigationController: Checking for Cookies...")
        // pull cookies
        let data: NSData? = defaults.objectForKey("sessionCookies") as? NSData
        if let cookie = data {
            let datas: NSArray? = NSKeyedUnarchiver.unarchiveObjectWithData(cookie) as? NSArray
            if let cookies = datas {
                for c in cookies as! [NSHTTPCookie] {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(c)
                }
            }
        }
        
        // Main navigation depending on cookies
        if cookiesPresent() {
            print("NavigationController: Cookies present and user is logged in, checking whether ride has been placed.")
            if pickupPresent() {
                // check whether ride has already been deleted
                self.performSegueWithIdentifier("waitingViewController", sender: self)
            }
            else {
                print("NavigationController: No ride, seguing to MapViewController.")
                self.performSegueWithIdentifier("mapViewController", sender: self)
            }
        } else {
            print("NavigationController: Cookies not present, seguing to ViewController.")
            self.performSegueWithIdentifier("viewController", sender: self)
        }
        
        
        
    }
    
    func pickupPresent()->Bool{
        let pickupTime: AnyObject? = defaults.objectForKey("pickupTime")
        if (pickupTime == nil){
            return false
        }
        else {
            // check how long ago (in seconds) if greater than 5 hours (18000 sec) return false
            let end = NSDate()
            let dateAsString = "\(pickupTime!)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
            let date = dateFormatter.dateFromString(dateAsString)
            
            let timeInterval: Double = end.timeIntervalSinceDate(date!)
            if timeInterval > 18000 {
                self.defaults.setObject(nil, forKey: "pickupTime")
                self.defaults.setObject(nil, forKey: "rideID")
                return false
            } else {
                return true
            }
        }
    }
    
    func cookiesPresent()->Bool{
        let data: NSData? = defaults.objectForKey("sessionCookies") as? NSData
        if (data == nil){
            return false
        }
        else {
            return true
        }
    }
    
}