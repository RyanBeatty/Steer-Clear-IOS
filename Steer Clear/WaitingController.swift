//
//  WaitingController.swift
//  Steer Clear
//
//  Created by Rodolfo Giacoman on 8/4/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit

class WaitingController: UIViewController {

    @IBOutlet var etaLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupETA()
    }

    func setupETA() {
        var currentRideData = SCNetwork.getRideData()
        print(currentRideData["pickup_time"])
        var fullETA = toString(currentRideData["pickup_time"]!)
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        let date = formatter.dateFromString(fullETA)
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date!)
        let hour = components.hour
        let minutes = components.minute
        
        etaLabel.text = "\(hour):\(minutes)"
    }
    
    @IBAction func cancelRideButton(sender: AnyObject) {
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
