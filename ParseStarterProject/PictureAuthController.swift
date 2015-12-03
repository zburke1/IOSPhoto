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
    
    /////////////////////////////////////////////////////////////////
    //                     FOR DRAWING                             //
    /////////////////////////////////////////////////////////////////
   
    @IBOutlet weak var tempImageView: UIImageView!
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 7.0
    var opacity: CGFloat = 1.0
    var swiped = false
    /////////////////////////////////////////////////////////////////
    //                     END DRAWING                             //
    /////////////////////////////////////////////////////////////////
    
    @IBOutlet weak var signatureImage: UIImageView!
    @IBOutlet weak var numTotalLabel: UILabel!
    @IBOutlet weak var fullNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    //Added manually may crash
    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps////////////////////////////////////////////////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        ////////////////////////////////////////////////////////////////////////////
        print(mainImageReference)
        numTotalLabel.text = String(currentSignerNum) + " signed / " + String(imageCount) + " total"
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.LandscapeLeft, UIInterfaceOrientationMask.LandscapeRight]
        return orientation
    }
    
    func saveSignature(){
        if(fullNameText.text != "" && emailText.text != ""){
            
        
        let signatureUpload = PFObject(className: "Signatures")
        let imageData = UIImageJPEGRepresentation(signatureImage.image!, 1.0)
        let file = PFFile(name:  "signature.png", data: imageData!)
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
        fullNameText.text = ""
        emailText.text = ""
        signatureImage.image = UIImage(named: "Legalese.png")
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
                        self.performSegueWithIdentifier("authCancelSegue", sender: self)
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
    
    
    /////////////////////////////////////////////////////////////////
    //                     FOR DRAWING                             //
    /////////////////////////////////////////////////////////////////
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first as UITouch! {
            lastPoint = touch.locationInView(self.view)
        }
    }
    
    
    
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextStrokePath(context)
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first as UITouch! {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
    }
    
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(signatureImage.frame.size)
        signatureImage.image?.drawInRect(CGRect(x: 0, y: 0, width: signatureImage.frame.size.width, height: signatureImage.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: tempImageView.frame.minX-signatureImage.frame.minX, y:  tempImageView.frame.minY-signatureImage.frame.minY, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.Normal, alpha: opacity)
        signatureImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
    
    
    //Added manually may crash
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
