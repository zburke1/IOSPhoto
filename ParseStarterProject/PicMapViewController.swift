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

class PicMapViewController: UIViewController {
    var parseEventLocations = [PFObject]()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                
                // Clear existing country data
               // parseEvents.removeAll(keepCapacity: true)
                
                // Add country objects to our array
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
        
        
        
        
        
        
//        do {
//            parseEventLocations = try locationsQuery.findObjects()
//            print(parseEventLocations.count)
//            addPoints();
//        }
//        catch{
//            print("Get events failed")
//        }
    }
    
    func addPoints(){
        for post in parseEventLocations {
            let point = post["eventLocation"] as! PFGeoPoint
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
            annotation.title = post["eventName"] as! String
            
            self.mapView.addAnnotation(annotation)
        }
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
