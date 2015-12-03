//
//  SinglePicViewController.swift
//  IOSPhoto
//
//  Created by Zac Burke on 12/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI
import MobileCoreServices

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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.LandscapeLeft, UIInterfaceOrientationMask.LandscapeRight]
        return orientation
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
        let parseImage = imageShown!["Image"] as! PFFile
        print(String(parseImage.url))
        PFCloud.callFunctionInBackground("MailGunSend", withParameters: ["imageId": (imageShown?.objectId)!,"imageUrl":parseImage.url!]) { results, error in
            if error == nil {
                // Your error handling here
                print("Success sending email function")
               self.emailSendSuccess()
            } else {
                // Deal with your results (votes in your case) here.
                print("Fail")
                self.emailSendFail()
            }
        }

    }
    
    
    func emailSendSuccess(){
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title: "Success", message: "Your email is on the way", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    func emailSendFail(){
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title: "Email failed", message: "Your email failed. Try sending it through the print option instead.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func printImageButton(sender: AnyObject) {
        
        let image = singleImageView.image
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .Photo
        printInfo.jobName = "EventPrint"
        let printActivityItems: [AnyObject] = [
            printInfo,
            image!
        ]
        
        
        var controller: UIActivityViewController = UIActivityViewController(activityItems: printActivityItems, applicationActivities: nil)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            self.presentViewController(controller, animated: true, completion: nil)
        }
        else {
            var popup: UIPopoverController = UIPopoverController(contentViewController: controller)
            popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any , animated: true)
        }
        
        
//        
//        let activityViewController = UIActivityViewController(activityItems: printActivityItems, applicationActivities: nil)
//        presentViewController(activityViewController, animated: false, completion: nil)
        
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
