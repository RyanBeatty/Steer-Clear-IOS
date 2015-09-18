//
//  TripConfirmation.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 7/29/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class TripConfirmation: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate  {

    @IBOutlet weak var requestRideOutlet: UIButton!
   
    @IBOutlet var startLocationOutlet: UILabel!

    @IBOutlet var changePickup: UIButton!
    @IBOutlet weak var changeDropoff: UIButton!
    @IBOutlet var endLocationOutlet: UILabel!
    @IBOutlet var myPicker: UIPickerView!

    @IBOutlet weak var numOfPassengers: UILabel!
    
    let pickerData = ["1","2","3","4","5", "6","7","8"]
    
    // ride object recieved from server
    var currentRide: Ride? = nil
    
    // start and end lat/long points
    var start = CLLocationCoordinate2D()
    var end = CLLocationCoordinate2D()
    
    // start and end address names
    var startName = ""
    var endName = ""
    var settings = Settings()
    var navWidth = CGFloat()
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var gear: UIImageView!

    var isRotating = false
    var shouldStopRotating = false
    
    override func viewDidLayoutSubviews() {
        self.navWidth = self.navigationBar.frame.width
        let navBorder = CALayer()
        navBorder.backgroundColor = settings.spiritGold.CGColor
        navBorder.frame = CGRect(x: 0, y: 44, width: self.navWidth, height: 5)
        navigationBar.layer.addSublayer(navBorder)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.gear.alpha = 0.0
        self.overlay.alpha = 0.0
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        myPicker.delegate = self
        myPicker.dataSource = self
        myPicker.selectRow(1, inComponent: 0, animated: true)
        
        let navBorder = CALayer()
        navBorder.backgroundColor = settings.spiritGold.CGColor
        navBorder.frame = CGRect(x: 0, y: 44, width: navWidth, height: 5)
        navigationBar.layer.addSublayer(navBorder)
        
        currentRide = nil

        startLocationOutlet.text = ("\(startName)")
        endLocationOutlet.text = ("\(endName)")
        
    }
    
    // called when making a segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // if seguing to waitingviewcontroller
        if (segue.identifier == "waitingSegue") {
            let svc = segue.destinationViewController as! WaitingController;
            
            // pass along ride object to waiting viewcontroller
            svc.currentRide = currentRide
            
        }
        else if (segue.identifier == "changeDetails") {
            
            let changeInfo = segue.destinationViewController as! MapViewController;
            changeInfo.change = true
            changeInfo.changeStart = start
            changeInfo.changeEnd = end
            changeInfo.changePickup = true
            changeInfo.changeStartName = startName
            changeInfo.changeEndName = endName
            
        }
        else if (segue.identifier == "changeDetails2") {
            
            let changeInfo = segue.destinationViewController as! MapViewController;
            changeInfo.change = true
            changeInfo.changeStart = start
            changeInfo.changeEnd = end
            changeInfo.changeStartName = startName
            changeInfo.changeEndName = endName
            
        }
    }
    
    /*
        confirmButton
        -------------
        Place ride request
    */
    @IBAction func confirmButton(sender: AnyObject) {
        let startLatString = String(start.latitude)
        let startLongString = String(start.longitude)
        let endLatString = String(end.latitude)
        let endLongString = String(end.longitude)
        let numPassengersString = numOfPassengers.text!
        requestRideOutlet.enabled = false
        
        UIView.animateWithDuration(0.5, animations: {
            self.gear.alpha = 1.0
            self.overlay.alpha = 1.0
        })
        
        if self.isRotating == false {
            self.gear.rotate360Degrees(completionDelegate: self)
            // Perhaps start a process which will refresh the UI...
        }
        
        
        // request a ride
        SCNetwork.requestRide(
            startLatString,
            startLong: startLongString,
            endLat: endLatString,
            endLong: endLongString,
            numPassengers: numPassengersString,
            completionHandler: {
                success, login, message, ride in
                
                // if something went wrong, display error message
                if(!success || ride == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.displayAlert("Ride Request Error", message: message)
                        self.overlay.alpha = 0.0
                        self.gear.alpha = 0.0
                        self.shouldStopRotating = true
                        self.requestRideOutlet.enabled = true
                    })
                }
                else {
                    // else request was a success, so change screens
                    dispatch_async(dispatch_get_main_queue(), {
                        // make sure we save Ride object
                        self.currentRide = ride
                        self.requestRideOutlet.enabled = true
                        self.performSegueWithIdentifier("waitingSegue", sender: self)
                    })
                }
            }
        )
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numOfPassengers.text = pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
       
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color  and center the label's background
            //pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
            pickerLabel.textAlignment = .Center
            
        }
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Avenir Next", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        
        return pickerLabel
        
    }
        
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //size the components of the UIPickerView
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
    
    func sendDetails(start_lat: Double, start_long: Double, end_lat: Double, end_long: Double) {

        let startLocation = CLLocation(latitude: start_lat, longitude: start_long)
        
        CLGeocoder().reverseGeocodeLocation(startLocation, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if let pm = placemarks?.first {
                print("Name: \(pm.name)")
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.gear.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
    }
}
