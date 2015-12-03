//
//  PicMapViewController.swift
//  IOSPhoto
//
//  Created by Zac Burke on 12/1/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class PicMapViewController: UIViewController,MKMapViewDelegate {
    var parseEventLocations = [PFObject]()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.LandscapeLeft, UIInterfaceOrientationMask.LandscapeRight]
        return orientation
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("Cleaning Map Memory")
        switch (self.mapView.mapType) {
        case MKMapType.Hybrid:
            self.mapView.mapType = MKMapType.Standard
            break;
        case MKMapType.Standard:
            self.mapView.mapType = MKMapType.Hybrid
            break;
        default:
            break;
        }
        
        self.mapView.delegate = nil
        self.mapView.removeFromSuperview()
        self.mapView = nil;
    }
    
    override func viewDidAppear(animated: Bool) {
        loadMapPoints()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMapPoints(){
        var query = PFQuery(className:"Events")
        
        var locationsQuery = query.whereKeyExists("eventLocation")
        // Fetch data from the parse platform
        
        
        locationsQuery.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            
            // The find succeeded now rocess the found objects into the countries array
            if error == nil {
                if let objects = objects {
                    self.parseEventLocations = Array(objects.generate())
                }
                
                // reload our data into the collection view
                self.addPoints();
                
            } else {
                // Log details of the failure
                print("SEARCH FAILED")
            }
        }
    }
    
    func addPoints(){
        print(parseEventLocations.count)
        for post in parseEventLocations {
            let point = post["eventLocation"] as! PFGeoPoint
            let annotation = MKPointAnnotation()
            print(CLLocationCoordinate2DMake(point.latitude, point.longitude))
            annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
            annotation.title = post["eventName"] as! String
            self.mapView.addAnnotation(annotation)
        }
        parseEventLocations = []
    }
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}
