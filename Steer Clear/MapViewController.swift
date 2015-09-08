//
//  MapViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 7/26/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import GoogleMaps
import QuartzCore
import Canvas

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    @IBOutlet var segmentOutlet: UISegmentedControl!

    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var dropOffButton: UIButton!
    
    @IBOutlet var destinationButton: UIButton!
    @IBOutlet var rideButton: UIButton!
    @IBOutlet var myLocationButtonOutlet: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!

    var globalStartLocation = CLLocationCoordinate2D()
    var globalEndLocation = CLLocationCoordinate2D()
    var changeStart = CLLocationCoordinate2D()
    var changeEnd = CLLocationCoordinate2D()
    var changeStartName = ""
    var changeEndName = ""
    
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker: GMSMarker!
    var endLocationMarker: GMSMarker!
    var locationDetails = ""
    var destinationInput = false
    var cameFromSearch = false
    var change = false
    var changePickup = false
    var globalStartName = ""
    var globalEndName = ""
    
    var networkController = Network()
    var settings = Settings()
    
    var geofence = CLCircularRegion()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var popOver: UIView!
    var popOverStartY = CGFloat()
    var popOverViewable = false
    
    @IBAction func segmentControlSwitch(sender: AnyObject) {
        switch segmentOutlet.selectedSegmentIndex
        {
        case 0:
            segmentOutlet.tintColor = settings.spiritGold
            if globalStartName != "" {
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(globalStartLocation,
                    zoom: settings.zoom, bearing: settings.bearing, viewingAngle: settings.viewingAngle))
            }
            
            
        case 1:
            segmentOutlet.tintColor = settings.wmGreen
            if globalEndName != "" {
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(globalEndLocation,
                    zoom: settings.zoom, bearing: settings.bearing, viewingAngle: settings.viewingAngle))
            }
           
            
        default:
            break;
        }
    }

    @IBAction func confirmRideButton(sender: AnyObject) {
        if (pickUpButton.titleLabel!.text == "Select a Pick Up Location") || (dropOffButton.titleLabel!.text == "Select a Drop Off Location") {
            let alert = UIAlertController(title: "Trip Error", message: "Please Select a Pick Up and Drop Off Location", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
        else {
            self.performSegueWithIdentifier("sendDetails", sender: self)
        
        }
    }
    
    
    @IBAction func myLocationButton(sender: AnyObject) {
        let myLocation = locationManager.location
        if myLocation != nil {
            mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 17.0, bearing: 30, viewingAngle: 45))
            self.setupLocationMarker(myLocation.coordinate)
        } else {
            let alert = UIAlertController(title: "Location Error", message: "Cannot find Current Location.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        if networkController.noNetwork() == false {
            let alert = UIAlertController(title: "Network Connection", message: "Unable to connect to the network.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            segmentOutlet.selectedSegmentIndex = 0
            segmentOutlet.tintColor = settings.spiritGold
            let gpaViewController = GooglePlacesAutocomplete(apiKey: settings.GMSAPIKEY, placeType: .Address)
            gpaViewController.placeDelegate = self
            gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 3219)
            presentViewController(gpaViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func dropOffSearchButton(sender: AnyObject) {
        if networkController.noNetwork() == false {
            let alert = UIAlertController(title: "Network Connection", message: "Unable to connect to the network.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            segmentOutlet.selectedSegmentIndex = 1
            segmentOutlet.tintColor = settings.wmGreen
            let gpaViewController = GooglePlacesAutocomplete(apiKey: settings.GMSAPIKEY, placeType: .Address)
            gpaViewController.placeDelegate = self
            gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 1000)
            presentViewController(gpaViewController, animated: true, completion: nil)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        
        self.popOverStartY = self.popOver.frame.origin.y
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        self.geofence = CLCircularRegion(center: settings.geofenceCenter, radius: 3219, identifier: "serviceGeofence")
        
        if change == true {
            if changePickup == true {
                self.globalStartLocation = changeStart
                self.globalEndLocation = changeEnd
                self.globalStartName = changeStartName
                self.globalEndName = changeEndName
                self.dropOffButton.setTitle("\(globalEndName)", forState: UIControlState.Normal)
                setupLocationMarker(changeStart)
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(changeStart, zoom: 17.0, bearing: 30, viewingAngle: 45))
                changePickup == false
                
                
                self.setupLocationMarker(changeStart)
                endLocationMarker = GMSMarker(position: changeEnd)
                endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
                endLocationMarker.icon = GMSMarker.markerImageWithColor(settings.wmGreen)
                endLocationMarker.title = "Drop Off"
                // endLocationMarker.snippet = "\(locationDetails)"
                println(locationDetails)
                endLocationMarker.opacity = 0.75
                endLocationMarker.map = mapView
                globalEndLocation.latitude = changeEnd.latitude
                globalEndLocation.longitude = changeEnd.longitude
                destinationInput = true
                
            } else {
                println("change pickup is not equal to true")
                self.globalStartLocation = changeStart
                self.globalEndLocation = changeEnd
                self.globalStartName = changeStartName
                self.globalEndName = changeEndName
                self.pickUpButton.setTitle("\(globalStartName)", forState: UIControlState.Normal)
                setupLocationMarker(changeStart)
                segmentOutlet.selectedSegmentIndex = 1
                segmentOutlet.tintColor = settings.wmGreen
                self.setupLocationMarker(changeEnd)
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(changeEnd, zoom: 17.0, bearing: 30, viewingAngle: 45))
                changePickup == false
                
            }
            change = false
            
        } else {
            mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
            
        }
        mapView.delegate = self
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as! CLLocation
            mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 17.0, bearing: 30, viewingAngle: 45))
            //mapV.settings.myLocationButton = true
            self.setupLocationMarker(myLocation.coordinate)
            didFindMyLocation = true
        } else {
            println("could not find location")
        }
    }
    //This function detects a long press on the map and places a marker at the coordinates of the long press.
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        //Set variable to latitude of didLongPressAtCoordinate
        var lat = coordinate.latitude
        
        //Set variable to longitude of didLongPressAtCoordinate
        var long = coordinate.longitude
        
        //Feed position to mapMarker
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        if self.geofence.containsCoordinate(coordinate){
            self.setupLocationMarker(coordinate)
        } else {
            let alert = UIAlertController(title: "Region Error", message: "The location you have chosen is outside of Steer Cleer's service area.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons() {
        
        segmentOutlet.tintColor = settings.spiritGold
        
        pickUpButton.layer.shadowOpacity = 0.2
        dropOffButton.layer.shadowOpacity = 0.2
        
        //adds left block to pickup location button (yellow)
        var border = CALayer()
        border.backgroundColor = settings.spiritGold.CGColor
        border.frame = CGRect(x: -20, y: 0, width: 20, height: 36)
        pickUpButton.layer.addSublayer(border)
        
        //dropoff left block (green)
        var border1 = CALayer()
        border1.backgroundColor = settings.wmGreen.CGColor
        border1.frame = CGRect(x: -20, y: 0, width: 20, height: 36)
        dropOffButton.layer.addSublayer(border1)
        
//        myLocationButtonOutlet.layer.cornerRadius = 0.5 * myLocationButtonOutlet.bounds.size.width
        myLocationButtonOutlet.layer.shadowOpacity = 0.2
        
        
        
        
    }
    
    
    
    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
        if networkController.noNetwork() == false {
            let alert = UIAlertController(title: "Network Connection", message: "Unable to connect to the network.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            
            networkController.geocodeAddress(coordinate.latitude, long: coordinate.longitude)
            
            var placesClient: GMSPlacesClient?
            placesClient = GMSPlacesClient()
            
            placesClient!.lookUpPlaceID(networkController.fetchedID, callback: { (place, error) -> Void in
                if error != nil {
                    println("lookup place id query error: \(error!.localizedDescription)")
                    return
                }
                
                if place != nil && self.cameFromSearch == false {
                    if self.segmentOutlet.selectedSegmentIndex == 0 {
                        self.pickUpButton.setTitle("\(place!.name)", forState: UIControlState.Normal)
                        self.globalStartName = place!.name
                        self.globalStartLocation = coordinate
                    } else {
                        self.dropOffButton.setTitle("\(place!.name)", forState: UIControlState.Normal)
                        self.globalEndName = place!.name
                        self.globalEndLocation = coordinate
                    }
                    
                } else {
                    println("No place details for \(self.networkController.fetchedID)")
                }
                self.cameFromSearch = false
            })
            
            if segmentOutlet.selectedSegmentIndex == 0 {
                
                if locationMarker != nil {
                    locationMarker.map = nil
                }
                
                locationMarker = GMSMarker(position: coordinate)
                locationMarker.appearAnimation = kGMSMarkerAnimationPop
                locationMarker.icon = GMSMarker.markerImageWithColor(settings.spiritGold)
                locationMarker.title = "Pick Up"
                locationMarker.opacity = 0.75
                locationMarker.map = mapView
                globalStartLocation.latitude = coordinate.latitude
                globalStartLocation.longitude = coordinate.longitude
                
                
                
            } else {
                if endLocationMarker != nil {
                    endLocationMarker.map = nil
                }
                endLocationMarker = GMSMarker(position: coordinate)
                endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
                endLocationMarker.icon = GMSMarker.markerImageWithColor(settings.wmGreen)
                endLocationMarker.title = "Drop Off"
                println(locationDetails)
                endLocationMarker.opacity = 0.75
                endLocationMarker.map = mapView
                globalEndLocation.latitude = coordinate.latitude
                globalEndLocation.longitude = coordinate.longitude
                destinationInput = true
                
            }
            
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sendDetails") {
            
            var tripInfo = segue.destinationViewController as! TripConfirmation;
            
            tripInfo.start = self.globalStartLocation
            tripInfo.end = self.globalEndLocation
            
            tripInfo.startName = self.globalStartName
            tripInfo.endName = self.globalEndName
            
        }
    }
    
}

extension MapViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        place.getDetails { details in
            let tempCoord = CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude)
            if self.geofence.containsCoordinate(tempCoord){
                
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(details.latitude, longitude: details.longitude, zoom: 17.0, bearing: 30, viewingAngle: 45))
                let coordinate = CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude)
                
                if self.segmentOutlet.selectedSegmentIndex == 0 {
                    self.pickUpButton.setTitle("\(place.description)", forState: UIControlState.Normal)
                }
                else {
                    self.dropOffButton.setTitle("\(place.description)", forState: UIControlState.Normal)
                }
                
                self.cameFromSearch = true
                
                self.setupLocationMarker(coordinate)
                
                if self.segmentOutlet.selectedSegmentIndex == 0 {
                    self.globalStartName = place.description
                    self.globalStartLocation = coordinate
                } else {
                    self.globalEndName = place.description
                    self.globalEndLocation = coordinate
                }
                println(details)
            } else {
                let alert = UIAlertController(title: "Region Error", message: "The location you have chosen is outside of Steer Cleer's service area.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
        
        
        self.locationDetails = place.description
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func popUp(sender: AnyObject) {
        
        if !popOverViewable {
            UIView.animateWithDuration(
                0.5,
                animations: {
                    self.popOver.frame.origin.y = self.popOverStartY + 600
                },
                completion: nil
            )
            popOverViewable = true
        } else {
            UIView.animateWithDuration(
                0.5,
                animations: {
                    self.popOver.frame.origin.y = self.popOverStartY - 600
                },
                completion: nil
            )
            popOverViewable = false
            
        }
            


    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        self.defaults.setObject(nil, forKey: "sessionCookies")
        self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
    
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}