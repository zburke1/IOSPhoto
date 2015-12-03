/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit
import CoreLocation
import Parse

class EventCreationController: UIViewController,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var EventTitle: UITextField!
    @IBOutlet weak var EventDescription: UITextField!
    @IBOutlet weak var MapCheck: UISwitch!
    var Location = CLLocation()
    
    var currentEvent : PFObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CreateEvent(sender: AnyObject) {
        let event = PFObject(className: "Events")
        if(MapCheck.on){
            getLocation();
            event["eventName"] = EventTitle!.text
            event["eventDescription"] = EventDescription!.text
            event["eventLocation"] = PFGeoPoint(location: Location)
            
            event.saveInBackgroundWithBlock {
                (success: Bool, error:NSError?) -> Void in
                
                if(success)
                {
                    //Image Saved
                    print("Created event")
                    self.currentEvent = event
                    self.performSegueWithIdentifier("CreateEventSeque", sender: self)
                }
                else
                {
                    //Problem Occured
                    print("Error")
                }
        }
            
            
        }
        else{
            event["eventName"] = EventTitle!.text
            event["eventDescription"] = EventDescription!.text
            
            
            event.saveInBackgroundWithBlock {
                (success: Bool, error:NSError?) -> Void in
                
                if(success)
                {
                    //Image Saved
                    print("Created event")
                    self.performSegueWithIdentifier("CreateEventSeque", sender: self)
                }
                else
                {
                    //Problem Occured
                    print("Error")
                }
            }
        }
        
    }
    
    
    func getLocation(){
//        if #available(iOS 8.0, *) {
//            locationManager.requestAlwaysAuthorization()
//        } else {
//            // Fallback on earlier versions
//        }
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()        } else {
            // Fallback on earlier versions
        }
        
        if CLLocationManager.locationServicesEnabled() {
            print("Starting location search")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        Location = locationManager.location!
//        locationManager.stopUpdatingLocation()
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        Location = locationManager.location!
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateEventSeque"
        {
            
            
            let singleScene = segue.destinationViewController as! SingleEventController
            singleScene.currentEvent = currentEvent
            
        }
    }
    
}