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

var parseEvents = [PFObject]()
var Event = PFObject()

class HomePageController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
   
    var imageArray = [PFObject]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 7
        let cellLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadCollectionViewData()
    }
    
    func loadCollectionViewData(){
        var query = PFQuery(className:"Events")
        
        // Fetch data from the parse platform
        do {
            parseEvents = try query.findObjects()
            print(parseEvents.count)
            self.collectionView.reloadData()
        }
        catch{
            print("Get events failed")
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
        
        // Display "initial" flag image
        let initialThumbnail = UIImage(named: "imgPlaceholder.jpg")
        cell.customImage.image = initialThumbnail
        
//        // Fetch final flag image - if it exists
        if let value = parseEvents[indexPath.row]["eventThumb"] as? PFFile {
            let finalImage = parseEvents[indexPath.row]["eventThumb"] as? PFFile
            finalImage!.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.customImage.image = UIImage(data:imageData)
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentObject = parseEvents[indexPath.row]
        performSegueWithIdentifier("EventSelectedSegue", sender: currentObject)
    }
    
    //                                                              //
    //==============================================================//
    //Collection View                                               //
    //==============================================================//
    //                                                              //
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventSelectedSegue"
        {
            var currentObject : PFObject?
            if let event = sender as? PFObject{
                currentObject = sender as? PFObject
            } else {
                // No cell selected in collectionView - must be a new country record being created
                currentObject = PFObject(className:"Countries")
            }
            let singleScene = segue.destinationViewController as! SingleEventController
            singleScene.currentEvent = (currentObject)
            
        }
    }


}
    
    
    
    
    
    
    
    
    
    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//            let imageInfo: PFObject = imageArray[indexPath.row] as PFObject
//            
//            var cell:ControllerCell!  = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ControllerCell
//            if cell == nil {
//                
//                cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? ControllerCell
//            }
//        cell.customTitle.text = String("TEST")
//
//           // cell.customTitle.text = String(imageInfo["imageName"])
//           // print(String(imageInfo["imageName"]) + " image name")
//            let userImageFile = imageInfo["image"] as! PFFile
//            userImageFile.getDataInBackgroundWithBlock {
//                (imageData: NSData?, error: NSError?) -> Void in
//                if error == nil {
//                    if let imageData = imageData {
//                        let image = UIImage(data:imageData)
//                        cell.customImage.image = image
//                    }
//                }
//            }
//            
//            return cell
//    }
    
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let imageInfo: PFObject = imageArray[indexPath.row] as PFObject
//        let userImageFile = imageInfo["image"] as! PFFile
//        userImageFile.getDataInBackgroundWithBlock {
//            (imageData: NSData?, error: NSError?) -> Void in
//            if error == nil {
//                if let imageData = imageData {
//                    let image = UIImage(data:imageData)
//                    self.imageSelected = image!
//                    self.performSegueWithIdentifier("homeImageView", sender: self)
//                }
//            }
//            else{
//                print("Get image selection failed")
//            }
//        }
//        
//        
//    }
    
    

