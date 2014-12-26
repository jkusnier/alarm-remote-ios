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
        var response: NSURLResponse?
        var error: NSError?
        
        let jsonString = "{\"user_id\":\"\(userNameField.text)\", \"password\":\"\(passwordField.text)\"}"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var result:NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)

        HUDController.sharedController.hide()
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode == 200) {
                let jsonDict = NSJSONSerialization.JSONObjectWithData(result!, options: nil, error: &error) as NSDictionary
                if let accessToken = jsonDict.valueForKey("accessToken") as? String {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setValue(userNameField.text, forKey: Constants.kDefaultsUsernameKey)
                    
                    self.accessTokenField.text = accessToken
                    self.doneButton.enabled = true
                }
            } else {
                println("HTTP response: \(httpResponse.statusCode)")
                let alert = UIAlertController(title: "Error Authenticating", message: "Check Credentials", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            println("No HTTP response")
            let alert = UIAlertController(title: "Error Authenticating", message: "Check Credentials", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        let authToken = accessTokenField.text
        
        if (!authToken.isEmpty) {
            HUDController.sharedController.contentView = HUDContentView.ProgressView()
            HUDController.sharedController.show()
            
            let m_authUrl = authUrl.stringByAppendingFormat("?access_token=%@", self.accessTokenField.text)
            let jsonData = NSData(contentsOfURL: NSURL(string: m_authUrl)!)
            
            HUDController.sharedController.hide()
            if (jsonData != nil) {
                var error: NSError?
                let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary
                
                if (self.userNameField.text == jsonDict.valueForKey("_id") as? String) {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setValue(accessTokenField.text, forKey: Constants.kDefaultsAuthKey)

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
