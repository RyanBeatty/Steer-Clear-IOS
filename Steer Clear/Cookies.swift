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
        
        //因为程序存在relogin过程，所以需要判断当前cookies是否被清空
        var userDefaults: NSUserDefaults = self.userDefaults
        
        if userDefaults.objectForKey("sessionCookies") != nil {
            
            let arcCookies: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("sessionCookies") as! NSData)!
            var originalSet: NSMutableSet = NSMutableSet(array: (arcCookies as! NSArray) as [AnyObject])
            var nextSet: NSMutableSet = NSMutableSet(array: tempCookies as NSArray as [AnyObject])
            
            originalSet.unionSet(nextSet as Set<NSObject>)
            
            var datas: NSData = NSKeyedArchiver.archivedDataWithRootObject(originalSet.allObjects)
            userDefaults.setObject(datas, forKey: "sessionCookies")
            userDefaults.synchronize()
            
        }else{
            var datas: NSData = NSKeyedArchiver.archivedDataWithRootObject(tempCookies as [AnyObject])
            userDefaults.setObject(datas, forKey: "sessionCookies")
            userDefaults.synchronize()
        }
    }
    
    class func getCookies() -> NSArray {
        var userDefaults: NSUserDefaults = self.userDefaults
        return NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("sessionCookies") as! NSData) as! NSArray
    }

}