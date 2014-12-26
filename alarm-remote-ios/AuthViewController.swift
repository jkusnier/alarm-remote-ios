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
    
    let authUrl:String = "http://api.weecode.com/alarm/v1/users"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userName:NSString? = defaults.valueForKey(Constants.kDefaultsUsernameKey) as? NSString {
            userNameField.text = userName
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func getTokenPressed(sender: AnyObject) {
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        var request = NSMutableURLRequest(URL: NSURL(string: authUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        
        let jsonString = "{\"user_id\":\"\(userNameField.text)\", \"password\":\"\(passwordField.text)\"}"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            dispatch_async(dispatch_get_main_queue(), {
                HUDController.sharedController.hide()
                
                func showErrorAlert() {
                    let alert = UIAlertController(title: "Error Authenticating", message: "Check Credentials", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }

                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        var error: NSError?
                        let jsonDict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as NSDictionary
                        if let accessToken = jsonDict.valueForKey("accessToken") as? String {
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setValue(self.userNameField.text, forKey: Constants.kDefaultsUsernameKey)
                            
                            self.accessTokenField.text = accessToken
                            self.doneButton.enabled = true
                        }
                    } else {
                        showErrorAlert()
                    }
                } else {
                    showErrorAlert()
                }
            })
        })
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        let accessToken = self.accessTokenField.text
        
        if (!accessToken.isEmpty) {
            HUDController.sharedController.contentView = HUDContentView.ProgressView()
            HUDController.sharedController.show()
            
            let m_authUrl = authUrl.stringByAppendingFormat("?access_token=%@", accessToken)
            let jsonData = NSData(contentsOfURL: NSURL(string: m_authUrl)!)
            
            HUDController.sharedController.hide()
            if (jsonData != nil) {
                var error: NSError?
                let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary
                
                if (self.userNameField.text == jsonDict.valueForKey("_id") as? String) {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setValue(accessToken, forKey: Constants.kDefaultsAuthKey)

                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error Authenticating", message: "Auth Token is Invalid", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
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
