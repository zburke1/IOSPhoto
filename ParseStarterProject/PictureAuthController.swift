//
//  PictureAuthController.swift
//  IOSPhoto
//
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts

class PictureAuthController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var currentSignerNum = 0
    var imageCount = 0
    var mediaSwitchCheck = false
    var imageObject = ""
    var signatures = [PFObject]()
    var mainImageReference = ""
    var currentEvent : PFObject?
    
    @IBOutlet weak var signatureImage: UIImageView!
    @IBOutlet weak var numTotalLabel: UILabel!
    @IBOutlet weak var fullNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    //Added manually may crash
    override func viewDidLoad() {
        super.viewDidLoad()
        print(mainImageReference)
        numTotalLabel.text = String(currentSignerNum) + " signed / " + String(imageCount) + " total"
    }
    
    func saveSignature(){
        if(fullNameText.text != "" && emailText.text != ""){
            
        
        let signatureUpload = PFObject(className: "Signatures")
        let imageData = UIImageJPEGRepresentation(signatureImage.image!, 1.0)
        let file = PFFile(name: "event.png", data: imageData!)
        signatureUpload["signatureFile"] = file
        signatureUpload["EventImageRef"] = mainImageReference
        signatureUpload["signee"] = fullNameText.text
        signatureUpload["signeeEmail"] = emailText.text
        
            signatureUpload.saveInBackgroundWithBlock {
            (success: Bool, error:NSError?) -> Void in
            if(success){
                if(self.currentSignerNum != self.imageCount-1){
                    print("Signature taken")
                    self.updateViewAfterSignature()
                }
                else{
                    self.updateLastSignature()
                    print("Last signature taken")
                }
            }
            else{
             print("UPload failed")
            }
        }
        }
        else{
            print("Please fill in all fields")
        }

    }
    
    func updateViewAfterSignature(){
        currentSignerNum = currentSignerNum+1
        numTotalLabel.text = String(currentSignerNum) + " signed / " + String(imageCount) + " total"
    }
    
    func updateLastSignature(){
        numTotalLabel.text = "Finished"
        let query = PFQuery(className: "EventImages")
        var modQuery = query.whereKey("objectId", equalTo: mainImageReference)
        modQuery.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects{
                    for object in objects{
                        object["isAuth"] = true;
                        object.saveInBackgroundWithBlock({(Bool, error: NSError?) -> Void in })
                    }
                }
            }
            
        }
    }
    
    @IBAction func finishedButton(sender: AnyObject) {
        saveSignature();
    }
    
    
    @IBAction func cancelButton(sender: AnyObject) {
        performSegueWithIdentifier("authCancelSegue", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "authCancelSegue"
        {
            let svc  = segue.destinationViewController as! SingleEventController
            svc.currentEvent = currentEvent
        }
    }
    
    
    
    
    //Added manually may crash
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
