//
//  MapViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 7/26/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import QuartzCore

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var button: UIButton!
    @IBOutlet var dropOffButtonText: UIButton!
    @IBOutlet var destinationButton: UIButton!
    @IBOutlet var rideButton: UIButton!
    @IBOutlet var myLocationButtonOutlet: UIButton!
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var dropOffLabel: UIButton!
    @IBOutlet var confirmRideOutlet: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    //    @IBOutlet var mapV: GMSMapView!
    var startLatitude = CLLocationDegrees()
    var startLongitude = CLLocationDegrees()
    var endLatitude = CLLocationDegrees()
    var endLongitude = CLLocationDegrees()
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
    
    
    
    let dropoffColor = UIColor(hue: 0.4444, saturation: 0.8, brightness: 0.34, alpha: 1.0) /* #115740 */
    let pickupColor = UIColor(red:0.94, green:0.70, blue:0.14, alpha:1.0)
    
    let spiritYellow = UIColor(red:0.94, green:0.70, blue:0.14, alpha:1.0)
    let green = UIColor(hue: 0.4444, saturation: 0.8, brightness: 0.34, alpha: 1.0) /* #115740 */
    
    @IBAction func segmentControlSwitch(sender: AnyObject) {
        switch segmentOutlet.selectedSegmentIndex
        {
        case 0:
            segmentOutlet.tintColor = self.spiritYellow
            if globalStartName != "" {
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(globalStartLocation,
                    zoom: 17.0, bearing: 30, viewingAngle: 45))
            }
            
            
        case 1:
            segmentOutlet.tintColor = self.green
            if globalEndName != "" {
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(globalEndLocation,
                    zoom: 17.0, bearing: 30, viewingAngle: 45))
            }
           
            
        default:
            break;
        }
    }

    @IBAction func confirmRideButton(sender: AnyObject) {
        if destinationInput != false {
        } else {
            let alert = UIAlertController(title: "Trip Error", message: "Please input Destination", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
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
            segmentOutlet.tintColor = self.spiritYellow
            let gpaViewController = GooglePlacesAutocomplete(apiKey: "AIzaSyDd_lRDKvpH6ao8KmLTDmQPB4wdhxfuEys",placeType: .Address)
            gpaViewController.placeDelegate = self
            gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 1000)
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
            segmentOutlet.tintColor = self.green
            let gpaViewController = GooglePlacesAutocomplete(apiKey: "AIzaSyDd_lRDKvpH6ao8KmLTDmQPB4wdhxfuEys",placeType: .Address)
            gpaViewController.placeDelegate = self
            gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 1000)
            presentViewController(gpaViewController, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if change == true {
            if changePickup == true {
                self.globalStartLocation = changeStart
                self.globalEndLocation = changeEnd
                self.globalStartName = changeStartName
                self.globalEndName = changeEndName
                self.dropOffButtonText.setTitle("\(globalEndName)", forState: UIControlState.Normal)
                setupLocationMarker(changeStart)
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(changeStart, zoom: 17.0, bearing: 30, viewingAngle: 45))
                changePickup == false
                
                
                self.setupLocationMarker(changeStart)
                endLocationMarker = GMSMarker(position: changeEnd)
                endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
                endLocationMarker.icon = GMSMarker.markerImageWithColor(dropoffColor)
                endLocationMarker.title = "Drop Off"
                // endLocationMarker.snippet = "\(locationDetails)"
                print(locationDetails)
                endLocationMarker.opacity = 0.75
                endLocationMarker.map = mapView
                endLatitude = changeEnd.latitude
                endLongitude = changeEnd.longitude
                destinationInput = true
                
            } else {
                print("change pickup is not equal to true")
                self.globalStartLocation = changeStart
                self.globalEndLocation = changeEnd
                self.globalStartName = changeStartName
                self.globalEndName = changeEndName
                self.button.setTitle("\(globalStartName)", forState: UIControlState.Normal)
                setupLocationMarker(changeStart)
                segmentOutlet.selectedSegmentIndex = 1
                segmentOutlet.tintColor = self.green
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
            print("could not find location")
        }
    }
    //This function detects a long press on the map and places a marker at the coordinates of the long press.
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        //Set variable to latitude of didLongPressAtCoordinate
        var lat = coordinate.latitude
        
        //Set variable to longitude of didLongPressAtCoordinate
        var long = coordinate.longitude
        
        //Feed position to mapMarker
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.setupLocationMarker(coordinate)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons() {
        
        segmentOutlet.tintColor = self.spiritYellow
        
        button.layer.shadowOpacity = 0.5
        dropOffButtonText.layer.shadowOpacity = 0.5
        
        //adds left block to pickup location button (yellow)
        var border = CALayer()
        border.backgroundColor = spiritYellow.CGColor
        border.frame = CGRect(x: -20, y: 0, width: 20, height: 36)
        button.layer.addSublayer(border)
        
        //dropoff left block (green)
        var border1 = CALayer()
        border1.backgroundColor = green.CGColor
        border1.frame = CGRect(x: -20, y: 0, width: 20, height: 36)
        dropOffButtonText.layer.addSublayer(border1)
        
        myLocationButtonOutlet.layer.cornerRadius = 0.5 * myLocationButtonOutlet.bounds.size.width
        myLocationButtonOutlet.layer.shadowOpacity = 0.5
        
        
        
        
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
                        self.button.setTitle("\(place!.name)", forState: UIControlState.Normal)
                        self.globalStartName = place!.name
                        self.globalStartLocation = coordinate
                    } else {
                        self.dropOffButtonText.setTitle("\(place!.name)", forState: UIControlState.Normal)
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
                locationMarker.icon = GMSMarker.markerImageWithColor(pickupColor)
                locationMarker.title = "Pick Up"
                locationMarker.opacity = 0.75
                locationMarker.map = mapView
                startLatitude = coordinate.latitude
                startLongitude = coordinate.longitude
                
                
                
            } else {
                if endLocationMarker != nil {
                    endLocationMarker.map = nil
                }
                endLocationMarker = GMSMarker(position: coordinate)
                endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
                endLocationMarker.icon = GMSMarker.markerImageWithColor(dropoffColor)
                endLocationMarker.title = "Drop Off"
                print(locationDetails)
                endLocationMarker.opacity = 0.75
                endLocationMarker.map = mapView
                endLatitude = coordinate.latitude
                endLongitude = coordinate.longitude
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
            self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(details.latitude, longitude: details.longitude, zoom: 17.0, bearing: 30, viewingAngle: 45))
            let coordinate = CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude)
            
            if self.segmentOutlet.selectedSegmentIndex == 0 {
                self.button.setTitle("\(place.description)", forState: UIControlState.Normal)
            }
            else {
                self.dropOffButtonText.setTitle("\(place.description)", forState: UIControlState.Normal)
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
            
        }
        
        
        self.locationDetails = place.description
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}