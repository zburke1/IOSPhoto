/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit
import Parse
import ParseUI
import Bolts

class SingleEventController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate, UICollectionViewDataSource {
    var parseEvents = [PFObject]()
    var imageCount = 0;
    var currentEvent : PFObject?
    var selectedImage : PFObject?
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 7
        let cellLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        eventNameLabel.text = currentEvent!["eventName"] as! String
        loadCollectionViewData()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.LandscapeLeft, UIInterfaceOrientationMask.LandscapeRight]
        return orientation
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("Cleaning Collection Memory")
        self.collectionView.delegate = nil
        self.collectionView.removeFromSuperview()
        self.collectionView = nil;
    }
    
    
    func loadCollectionViewData(){
        let query = PFQuery(className:"EventImages")
        query.includeKey("Events")
        var queryImages = query.whereKey("Events", equalTo: currentEvent!)
        
        query.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            
            // The find succeeded now rocess the found objects into the countries array
            if error == nil {
                
                
                // Add country objects to our array
                if var objects = objects as [PFObject]!{
                    objects = objects.reverse()
                    self.parseEvents = objects + self.parseEvents
                    
                }
                self.collectionView!.reloadData()
                
                
            } else {
                // Log details of the failure
                print(error?.description)
            }
            
        }
        
    }
    
    
    
    @IBAction func takePictureSelected(sender: AnyObject) {
        
        
        
        self.performSegueWithIdentifier("TakePictureSegue", sender: self)
    
        
    }
    
    
    //                                                              //
    //==============================================================//
    //Collection View                                               //
    //==============================================================//
    //                                                              //
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parseEvents.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ControllerCell
        
        // Display the country name
        if let value = parseEvents[indexPath.row].createdAt {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            let date = dateFormatter.stringFromDate(value)
            cell.customTitle.text = date
        }
        
        
        cell.customImage.image = UIImage(named: "imgPlaceholder.jpg")
        // initialThumbnail = nil
        cell.customImage.file = parseEvents[indexPath.row]["Image"] as? PFFile
        // remote image
        
        cell.customImage.loadInBackground()
        return cell
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedImage = parseEvents[indexPath.row]
        performSegueWithIdentifier("EventImageSelectedSegue", sender:self)
    }
    
    //                                                              //
    //==============================================================//
    //Cleaning Code                                                 //
    //==============================================================//
    //                                                              //
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TakePictureSegue"
        {
            let svc = segue.destinationViewController as! TakePictureController;
            svc.currentEvent = currentEvent
        }
        else if segue.identifier == "EventImageSelectedSegue" {
            let svc = segue.destinationViewController as! SinglePicViewController;
            svc.currentEvent = currentEvent
            svc.imageShown = selectedImage
        }
    }
}