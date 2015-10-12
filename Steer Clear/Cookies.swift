//
//  Cookies.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 9/6/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation



@objc class Cookies: NSObject {
    
    class var userDefaults: NSUserDefaults {
        
        return NSUserDefaults.standardUserDefaults()
    }
    
    
    class func setCookiesWithArr(tempCookies: NSArray) {
        
        let userDefaults: NSUserDefaults = self.userDefaults
        
        if userDefaults.objectForKey("sessionCookies") != nil {
            
            let arcCookies: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("sessionCookies") as! NSData)!
            let originalSet: NSMutableSet = NSMutableSet(array: (arcCookies as! NSArray) as [AnyObject])
            let nextSet: NSMutableSet = NSMutableSet(array: tempCookies as NSArray as [AnyObject])
            
            originalSet.unionSet(nextSet as Set<NSObject>)
            
            let datas: NSData = NSKeyedArchiver.archivedDataWithRootObject(originalSet.allObjects)
            userDefaults.setObject(datas, forKey: "sessionCookies")
            userDefaults.synchronize()
            
        }else{
            let datas: NSData = NSKeyedArchiver.archivedDataWithRootObject(tempCookies as [AnyObject])
            userDefaults.setObject(datas, forKey: "sessionCookies")
            userDefaults.synchronize()
        }
    }
    
    class func getCookies() -> NSArray {
        let userDefaults: NSUserDefaults = self.userDefaults
        return NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("sessionCookies") as! NSData) as! NSArray
    }
    
}