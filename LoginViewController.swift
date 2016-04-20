//
//  LoginViewController.swift
//  TransitAlarm
//
//  Created by Matthew Bracamonte on 4/20/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
        }
    }
    
    @IBAction func loginAttemptPressed(sender: UIButton) {
        if let email = emailTextField.text where email != "", let password = passwordTextField.text where password != "" {
            
            DataService.dataService.REF_BASE.authUser(email, password: password, withCompletionBlock: { error, authData in
                if error != nil {
                    print(error)
                    if error.code == STATUS_ERROR_ACCOUNT_NONEXIST {
                        DataService.dataService.REF_BASE.createUser(email, password: password, withValueCompletionBlock: { error, result in
                            if error != nil {
                                //error should never be thrown
                                self.showAlert("Could Not Create Account", message: "Account was not created, please try something else.")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue([KEY_UID], forKey: KEY_UID)
                                DataService.dataService.REF_BASE.authUser(email, password: password, withCompletionBlock: nil)
                                self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
                            }
                        })
                    } else {
                        //User exists but invalid email or password
                        self.showAlert("Could Not Login", message: "Please check username or password")
                    }
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
                }
            })
        } else {
            //Error thrown if password or email text field are empty
            showAlert("Email and Password Required", message: "You must enter a valid email and password")
        }
        
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
