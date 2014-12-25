//
//  AuthViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/24/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import PKHUD

class AuthViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var accessTokenField: UITextField!
    
    let authUrl:NSURL = NSURL(string: "http://api.weecode.com/alarm/v1/users")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func getTokenPressed(sender: AnyObject) {
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        var request = NSMutableURLRequest(URL: authUrl, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
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
                    accessTokenField.text = accessToken
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
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let authToken = accessTokenField.text
        
        if (!authToken.isEmpty) {
            defaults.setValue(accessTokenField.text, forKey: Constants.kDefaultsAuthKey)
        
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
