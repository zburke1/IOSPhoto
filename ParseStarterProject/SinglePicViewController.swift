//
//  SinglePicViewController.swift
//  IOSPhoto
//
//  Created by Zac Burke on 12/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class SinglePicViewController: UIViewController {

    @IBOutlet weak var isAuthorizedSwitch: UISwitch!
    var imageShown : PFObject?
    var currentEvent : PFObject?
    var people = [PFObject]()
    
    @IBOutlet weak var singleImageView: PFImageView!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authCheck = imageShown!["isAuth"] as! Bool
        if(authCheck){
            print("Not all people signed")
            isAuthorizedSwitch.setOn(true, animated: false)
        }
        
        findPeople();
        
        singleImageView.image = UIImage(named: "imgPlaceholder.jpg")
        singleImageView.file = imageShown!["Image"] as? PFFile
        singleImageView.loadInBackground()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findPeople(){
        let query = PFQuery(className: "Signatures")
        print((imageShown?.objectId)!)
        let queryMod = query.whereKey("EventImageRef", equalTo: (imageShown?.objectId)!)
        queryMod.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                
                
                // Add country objects to our array
                if var objects = objects as [PFObject]!{
                    objects = objects.reverse()
                    self.people = objects + self.people
                    print(self.people.count)
                }
            } else {
                // Log details of the failure
                print(error?.description)
            }
            
        }
    }
    
    @IBAction func emailPictureButton(sender: AnyObject) {
        //let parameters = ["eventImage": imageShown?.objectId]
       
        PFCloud.callFunctionInBackground("MailGunSend", withParameters: ["imageId": (imageShown?.objectId)!]) { results, error in
            if error == nil {
                // Your error handling here
                print("Success sending email function")
            } else {
                // Deal with your results (votes in your case) here.
                print("Fail")
            }
        }

    }
    
    @IBAction func printImageButton(sender: AnyObject) {
    
    }
    
    @IBAction func BackButton(sender: AnyObject) {
        performSegueWithIdentifier("pictureToEventSegue", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pictureToEventSegue"
        {
            let svc = segue.destinationViewController as! SingleEventController
            svc.currentEvent = currentEvent
        }
}
}
