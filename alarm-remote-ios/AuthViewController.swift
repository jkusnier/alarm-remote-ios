//
//  AuthViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/24/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import PKHUD

class AuthViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var accessTokenField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var centerDoneConstraint: NSLayoutConstraint!
    
    var presentingView:MainViewController?

    let api = APIController()
    
    let authUrl:String = "http://api.weecode.com/alarm/v1/users"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName:String? = self.defaults.stringForKey(Constants.kDefaultsUsernameKey) {
            if userNameField != nil {
                userNameField.text = userName
            }
        }
        if let accessToken:String? = self.defaults.stringForKey(Constants.kDefaultsAccessTokenKey) {
            if accessToken != nil {
                accessTokenField.text = accessToken
                self.doneButton.enabled = true
                self.cancelButton.hidden = false
            }
        }
        
        if !self.cancelButton.hidden {
            self.centerDoneConstraint.active = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func getTokenPressed(sender: AnyObject) {
        api.getAccessToken(userNameField.text, password: passwordField.text,
            failure: { error in
                let alert = UIAlertController(title: "Error Authenticating", message: "Check Credentials", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            },
            success: { accessToken in
                self.accessTokenField.text = accessToken
                self.doneButton.enabled = true
            }
        )
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        let accessToken = self.accessTokenField.text
        
        if (!accessToken.isEmpty) {
            HUDController.sharedController.contentView = HUDContentView.ProgressView()
            HUDController.sharedController.show()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                let m_authUrl = self.authUrl.stringByAppendingFormat("?access_token=%@", accessToken)
                let jsonData = NSData(contentsOfURL: NSURL(string: m_authUrl)!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    HUDController.sharedController.hide()

                    if (jsonData != nil) {
                        var error: NSError?
                        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary
                        
                        if (self.userNameField.text == jsonDict.valueForKey("_id") as? String) {
                            self.defaults.setValue(accessToken, forKey: Constants.kDefaultsAccessTokenKey)
                            
                            if self.presentingView != nil {
                                self.presentingView!.dismissAuthSettings()
                            } else {
                              self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        } else {
                            let alert = UIAlertController(title: "Error Authenticating", message: "Auth Token is Invalid", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                })
            });
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.accessTokenField) {
            let testString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            self.doneButton.enabled = !testString.isEmpty
        }
        
        return true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if (textField == self.accessTokenField) {
            self.doneButton.enabled = false
        }
        
        return true;
    }
}
