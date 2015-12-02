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
import MobileCoreServices
import AssetsLibrary


class TakePictureController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    var currentEvent : PFObject?
    var imageTaken = false
    var imageCount = 0
    var mediaSwitchCheck = false
    var postQuick = true
    var imagePosted = ""
    
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var mediaSwitch: UISwitch!
    @IBOutlet weak var amountOfPeople: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    
    var picker = UIImagePickerController()
   
    
    @IBOutlet weak var ImageFrame: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentEvent!["eventName"])
        
        let swipeLEFT = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLEFT.direction = UISwipeGestureRecognizerDirection.Left
        
        let swipeRIGHT = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRIGHT.direction = UISwipeGestureRecognizerDirection.Right
        
        view.addGestureRecognizer(swipeLEFT)
        view.addGestureRecognizer(swipeRIGHT)

        let gestTap = UITapGestureRecognizer(target: self, action: "tapped:")
        gestTap.numberOfTapsRequired = 1
        gestTap.numberOfTouchesRequired = 1
        
        view.addGestureRecognizer(gestTap)
        

    }
    
    func openCamera(){
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            picker.delegate = self
            picker.sourceType = .Camera
            picker.mediaTypes = [String(kUTTypeImage)]
            picker.allowsEditing = false
            
            if #available(iOS 8.0, *) { // iOS8
                picker.showsCameraControls = true
                self.presentViewController(picker, animated:true, completion:{})
            }
            
        }
        else{
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if(picker.sourceType == .Camera){
        self.dismissViewControllerAnimated(true, completion:nil)
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        
            UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
        }
        else{
            ImageFrame.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            imageTaken = false
            retakeButton.enabled = true
            goButton.enabled = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
       

        
    }
    

    
    func image(image: UIImage, didFinishSavingWithError error:NSError?, contextInfo: UnsafePointer<Void>)
    {
        if error == nil {
            print("SAVED")
            ImageFrame.image = image
            imageTaken = true
            retakeButton.enabled = true
            goButton.enabled = true
                   } else {
            print("FAILED TO SAVE")
   
        }
    }
    
    @IBAction func retakeButton(sender: AnyObject) {
        
        let parameters = ["": ""]	
        PFCloud.callFunctionInBackground("SendGrid", withParameters: parameters) { results, error in
            if error != nil {
                // Your error handling here
                print("Success")
            } else {
                // Deal with your results (votes in your case) here.
                print("Fail")
            }
        }
        
        
    }
    
    func postPicture(){
            progressSpinner.startAnimating()
            retakeButton.enabled = false
            goButton.enabled = false
            cancelButton.enabled = false
            let imageUpload = PFObject(className: "EventImages")
            imageUpload["amountOfPeople"] = Int(amountOfPeople!.text!)
            
            let imageData = UIImageJPEGRepresentation(ImageFrame.image!, 1.0)
            let file = PFFile(name: "event.png", data: imageData!)
            
            imageUpload["Image"] = file
            imageUpload["Events"] = currentEvent
        
                print("Updating event thumb")
                currentEvent!["eventThumb"] = file
            
            imageUpload["isAuth"] = false
            imageUpload.saveInBackgroundWithBlock {
                (success: Bool, error:NSError?) -> Void in
                
                if(success)
                {
                    //Image Saved
                    print("Saved image")
                    self.currentEvent?.saveInBackgroundWithBlock{
                        (success: Bool, error:NSError?) -> Void in
                        
                        if(success){
                            self.progressSpinner.stopAnimating()
                            if(self.postQuick){
                                 print("Updated thumbnail")
                                 self.performSegueWithIdentifier("pictureNoAuthSegue", sender: self)
                            }
                            else{
                                print("Segue to signatures")
                                self.imagePosted = imageUpload.objectId!
                                self.pictureAuth();
                            }
                            
                        }
                        else{
                                self.progressSpinner.stopAnimating()
                        }
                    }
                }
                else
                {
                    //Problem Occured
                    print("Error")
                    self.progressSpinner.stopAnimating()
                    self.retakeButton.enabled = true
                    self.goButton.enabled = true
                    self.cancelButton.enabled = true
                    self.mediaSwitchCheck = false
                    //TODO ADD Error alert!
                }
                
                
            }
        
        
    }
    
    
    @IBAction func goButton(sender: AnyObject) {
        if(mediaSwitch.on){
            mediaSwitchCheck = true
            if(amountOfPeople.text=="0" || amountOfPeople.text==""){
                amountOfPeople.text = "0"
                postQuick = true
                postPicture();
            }
            else{
                postQuick = false
                let countText = amountOfPeople.text!
                imageCount = Int(countText)!
                postPicture();
            }
        }
        else{
                mediaSwitchCheck = false
                if(amountOfPeople.text=="0" || amountOfPeople.text==""){
                    postQuick = true
                    amountOfPeople.text = "0"
                    postPicture();
                }
                else{
                    postQuick = false
                    let countText = amountOfPeople.text!
                    imageCount = Int(countText)!
                    postPicture();
                }
            
            
            
           
        }
    }
    
    func pictureAuth(){
        performSegueWithIdentifier("ImgAuthSegue", sender: self)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "cancelTakingPicture"
        {
            let svc = segue.destinationViewController as! SingleEventController;
            svc.currentEvent = currentEvent
        }
        else if segue.identifier == "pictureNoAuthSegue"{
            let svc = segue.destinationViewController as! SingleEventController;
            svc.currentEvent = currentEvent
        }
        else if segue.identifier == "ImgAuthSegue"
        {
            let svc = segue.destinationViewController as! PictureAuthController
            svc.imageCount = imageCount
            svc.mediaSwitchCheck = mediaSwitchCheck
            svc.mainImageReference = imagePosted
            svc.currentEvent = currentEvent
        }
    }
    
    
    
    func tapped(gesture: UITapGestureRecognizer){
        
        if CGRectContainsPoint(self.ImageFrame.frame,gesture.locationInView(self.view))
        {
            if(!imageTaken){
          print("Image Tapped")
                openCamera()
            }
            else{
                print("Image already taken")
            }
            }
            
        }
    
    func swiped(gesture: UISwipeGestureRecognizer){
        print(gesture.direction)
        
        if CGRectContainsPoint(self.ImageFrame.frame, gesture.locationInView(self.view))
        {
            print("low e")
        }
}
}

