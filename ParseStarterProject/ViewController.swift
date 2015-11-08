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

class ViewController: UIViewController {

    @IBOutlet var usernameText: UITextField!
    @IBOutlet var passwordText: UITextField!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loginGo(sender: AnyObject) {
            if usernameText.text !=  "" && passwordText.text != "" {
                PFUser.logInWithUsernameInBackground(usernameText.text!, password:passwordText.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil
                    {
                        // Do stuff after successful login.
                        print("You logged in")
                        self.performSegueWithIdentifier("mainLoginSegue", sender: self)
        
                    }
                    else
                    {
                        if(error?.code==101){
                            let alertView = UIAlertView(title: "Oops!", message: "Your user/password is incorrect", delegate: nil, cancelButtonTitle: "OK")
                            alertView.show()
                            print(error?.description)
                        }
                    }
                }
                
                
            }
    
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



//@IBAction func loginGo(sender: AnyObject) {
//    if usernameText.text !=  "" && passwordText.text != "" {
//        PFUser.logInWithUsernameInBackground(usernameText.text!, password:passwordText.text!) {
//            (user: PFUser?, error: NSError?) -> Void in
//            if user != nil
//            {
//                // Do stuff after successful login.
//                print("You logged in")
//                self.performSegueWithIdentifier("mainLoginSegue", sender: self)
//                
//            }
//            else
//            {
//                if(error?.code==101){
//                    let alertView = UIAlertView(title: "Oops!", message: "Your user/password is incorrect", delegate: nil, cancelButtonTitle: "OK")
//                    alertView.show()
//                    print(error?.description)
//                }
//            }
//        }
//        
//        
//    }
