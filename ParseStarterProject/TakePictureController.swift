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


class TakePictureController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    var currentEvent : PFObject?
    var imageTaken = false;
    var imageCount = 0;
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var mediaSwitch: UISwitch!
    @IBOutlet weak var amountOfPeople: UITextField!
    
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    
    var picker = UIImagePickerController()
    
    @IBOutlet weak var ImageFrame: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
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
//        picker.sourceType = UIImagePickerControllerSourceType.Camera
//        picker.allowsEditing = true
//        self.presentViewController(picker, animated: true, completion: nil)
        
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        ImageFrame.image = image
        imageTaken = false;
        retakeButton.enabled = true
        goButton.enabled = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if picker.sourceType == UIImagePickerControllerSourceType.Camera
        {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo", nil)
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error:NSError?, contextInfo: UnsafePointer<Void>)
    {
        if error == nil
        {
            
        }
    }
    
    @IBAction func retakeButton(sender: AnyObject) {
        
        let parameters = ["": ""]
        PFCloud.callFunctionInBackground("SendGrid", withParameters: paramaters) { results, error in
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
            let imageUpload = PFObject(className: "EventImages")
            imageUpload["amountOfPeople"] = Int(amountOfPeople!.text!)
            
            let imageData = UIImageJPEGRepresentation(ImageFrame.image!, 1.0)
            let file = PFFile(name: "event.png", data: imageData!)
            
            imageUpload["Image"] = file
            imageUpload["Events"] = currentEvent
            if(imageCount==0){
                currentEvent!["eventThumb"] = file
            }
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
                            self.performSegueWithIdentifier("pictureNoAuthSegue", sender: self)
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
                }
                
                
            }
        
        
    }
    
    
    @IBAction func goButton(sender: AnyObject) {
        if(mediaSwitch.on){
        
        }
        else{
            postPicture();
        }
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
    
    
    
    
    //pictureNoAuthSegue
    //cancelTakingPicture
}

