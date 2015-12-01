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

class SingleEventController: UIViewController {
    
    var imageCount = 0;
    var currentEvent : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(currentEvent!["eventName"])
    }
    
    
    @IBAction func takePictureSelected(sender: AnyObject) {
        
        
        
        self.performSegueWithIdentifier("TakePictureSegue", sender: self)
    
        
    }
    
    
    
    
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
    }
}