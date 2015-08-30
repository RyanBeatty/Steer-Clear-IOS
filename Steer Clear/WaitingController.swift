//
//  WaitingController.swift
//  Steer Clear
//
//  Created by Rodolfo Giacoman on 8/4/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import QuartzCore

class WaitingController: UIViewController {

    @IBOutlet var etaLabel: UILabel!
    
    var currentRide: Ride!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupETA()
    }

    func setupETA() {
//         time in UTC we need to
        var fullETA = toString(currentRide.pickupTime)
        
        if fullETA != "" {

            
            let dateAsString = "\(fullETA)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
            let date = dateFormatter.dateFromString(dateAsString)
            
            dateFormatter.dateFormat = "h:mm"
            let date24 = dateFormatter.stringFromDate(date!)
            
            etaLabel.text = "\(date24)"
        } else {
            println("For some reason eta not given.")
        }

        
    }
    
    @IBAction func cancelRideButton(sender: AnyObject) {
        var currentRideId = toString(currentRide.id)
        
        SCNetwork.deleteRideWithId(currentRideId,
            completionHandler: {
                success, message in
                
                // can't make UI updates from background thread, so we need to dispatch
                // them to the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // check if registration succeeds
                    if(!success) {
                        // if it failed, display error
                        self.displayAlert("Ride Error", message: message)
                    } else {
                        
                        self.performSegueWithIdentifier("cancelRideSegue", sender: self)
                    }
                })
        })
        
        
    }
    
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
