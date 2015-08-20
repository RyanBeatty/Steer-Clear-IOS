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

   
    @IBOutlet var startLocationOutlet: UILabel!

    @IBOutlet var endLocationOutlet: UILabel!
    @IBOutlet var myPicker: UIPickerView!
    @IBOutlet var numberOfPassengers: UILabel!

    let pickerData = ["1","2","3","4","5", "6","7","8"]
    var start = CLLocationCoordinate2D()
    var end = CLLocationCoordinate2D()
    var startName = ""
    var endName = ""
    var networkController = Network()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPicker.delegate = self
        myPicker.dataSource = self
        myPicker.selectRow(1, inComponent: 0, animated: true)

        startLocationOutlet.text = ("\(startName)")
        endLocationOutlet.text = ("\(endName)")
        
    }
    
    @IBAction func confirmButton(sender: AnyObject) {
        let stringStartLat = toString(start.latitude)
        let stringStartLong = toString(start.longitude)
        let stringEndLat = toString(end.latitude)
        let stringEndLong = toString(end.longitude)

        
        SCNetwork.add(stringStartLat,
                        start_long: stringStartLong,
                        end_lat: stringEndLat,
                        end_long: stringEndLong,
                        numOfPassengers: numberOfPassengers.text!,
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
                                  
                                    self.performSegueWithIdentifier("waitingSegue", sender: self)
                                }
                            })
                        })
        
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberOfPassengers.text = pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()

            //color  and center the label's background
            let hue = CGFloat(row)/CGFloat(pickerData.count)
            //pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
            pickerLabel.textAlignment = .Center
            
        }
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
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
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                println("Name: \(pm.name)")

            }
            else {
                println("Problem with the data received from geocoder")
            }
        })
        
        
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "changeDetails") {
            
            var changeInfo = segue.destinationViewController as! MapViewController;
            changeInfo.change = true
            changeInfo.changeStart = start
            changeInfo.changeEnd = end
            changeInfo.changePickup = true
            changeInfo.changeStartName = startName
            changeInfo.changeEndName = endName
            
        }
        if (segue.identifier == "changeDetails2") {
            
            var changeInfo = segue.destinationViewController as! MapViewController;
            changeInfo.change = true
            changeInfo.changeStart = start
            changeInfo.changeEnd = end
            changeInfo.changeStartName = startName
            changeInfo.changeEndName = endName
            
        }
        
    }

    

}
