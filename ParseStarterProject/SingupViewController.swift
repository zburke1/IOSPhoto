//
//  SingupViewController.swift
//  IOSPhoto
//
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SingupViewController: UIViewController {

    @IBOutlet var userNameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var pwdText: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signupFunc(sender: AnyObject) {
        if userNameText.text != "" && emailText.text != "" && pwdText.text != "" {
            let user = PFUser()
            user.username = userNameText.text
            user.password = pwdText.text
            user.email = emailText.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? NSString
                    print(errorString)
                    if(error.code == 202){
                        let alertView = UIAlertView(title: "Oops!", message: "That username is taken", delegate: nil, cancelButtonTitle: "OK")
                        alertView.show()
                    }
                    else if(error.code == 203){
                        let alertView = UIAlertView(title: "Oops!", message: "That email is already taken", delegate: nil, cancelButtonTitle: "OK")
                        alertView.show()
                    }
                } else {
                    print("You have succesfully signed up! Now logging in")
                   // self.loginFunc()
                }
            }
            
            
        }
        else{
            let alertView = UIAlertView(title: "Oops!", message: "Please fill in all fields before submitting", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}