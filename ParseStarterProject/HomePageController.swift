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

class HomePageController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate, UICollectionViewDataSource {
    
   
    var currentObject : PFObject?
   var parseEvents = [PFObject]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 7
        let cellLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        loadCollectionViewData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("Cleaning Collection Memory")
        self.collectionView.delegate = nil
        self.collectionView.removeFromSuperview()
        self.collectionView = nil;
    }
    
    
    
    func loadCollectionViewData(){
        var query = PFQuery(className:"Events")
        
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
        if let value = parseEvents[indexPath.row]["eventName"] as? String {
            cell.customTitle.text = value
        }
        
        
        cell.customImage.image = UIImage(named: "imgPlaceholder.jpg")
       // initialThumbnail = nil
        cell.customImage.file = parseEvents[indexPath.row]["eventThumb"] as? PFFile
        // remote image
        
         cell.customImage.loadInBackground()
        return cell
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentObject = parseEvents[indexPath.row] as PFObject
        performSegueWithIdentifier("EventSelectedSegue", sender:
 self)
    }
    
    
    //==============================================================//
    //Collection View                                               //
    //==============================================================//
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       print("Running")
        parseEvents = []
        collectionView.layoutIfNeeded()
        PFQuery.clearAllCachedResults()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        if segue.identifier == "EventSelectedSegue"
        {
            let singleScene = segue.destinationViewController as! SingleEventController
            singleScene.currentEvent = currentObject
            
        }
    }


}