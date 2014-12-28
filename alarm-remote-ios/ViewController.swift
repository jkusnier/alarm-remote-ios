//
//  ViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/24/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import PKHUD

class ViewController: UIViewController {

    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var topToolbarConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var devices = [String: [String: AnyObject?]]()
    
    let selectedDeviceLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topToolbarConstraint.constant = UIApplication.sharedApplication().statusBarFrame.height
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let switchButton = UIBarButtonItem(title: "Switch", style: .Bordered, target: self, action: "showSelectDevice")
        let editButton = UIBarButtonItem(title: "Edit", style: .Bordered, target: nil, action: nil)
        
        self.topToolbar.items = [switchButton, flexibleSpace, UIBarButtonItem(customView: self.selectedDeviceLabel), flexibleSpace, editButton]
        
        if defaults.stringForKey(Constants.kDefaultsAccessTokenKey) != nil {
            self.updateDevices()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.defaults.stringForKey(Constants.kDefaultsAccessTokenKey) == nil) {
            self.performSegueWithIdentifier("showAuth", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if contains(["showAuth", "showAuthSettings"], segue.identifier!) {
            if let destView = segue.destinationViewController as? AuthViewController {
                destView.presentingView = self
            }
        } else if (segue.identifier == "showSelectDevice") {
            if let destView = segue.destinationViewController as? SelectDeviceTableViewController {
                destView.presentingView = self
                destView.devices = self.devices
            }
        }
    }
    
    func dismissAuthSettings() {
        self.modelChanged()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateDevices() {
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        let accessToken:NSString = defaults.stringForKey(Constants.kDefaultsAccessTokenKey)!
        let devicesUrl = "http://api.weecode.com/alarm/v1/devices?access_token=\(accessToken)"
        
        var request = NSMutableURLRequest(URL: NSURL(string: devicesUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                HUDController.sharedController.hide()
                
                func showErrorAlert() {
                    let alert = UIAlertController(title: "Error", message: "Error Retrieving Data", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        var error: NSError?
                        let jsonArr:NSArray? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as? NSArray
                        
                        if error != nil || jsonArr == nil {
                            showErrorAlert()
                        } else {
                            for item in jsonArr! {
                                if let dict = item as? NSDictionary {
                                    let m_id = dict.valueForKey("_id") as? String
                                    let m_name = dict.valueForKey("name") as? String
                                    let m_zip = dict.valueForKey("zip") as? Int
                                    let m_timeZone = dict.valueForKey("timeZone") as? Int
                                    let m_owner = dict.valueForKey("owner") as? String
                                    
                                    self.devices[m_id!] = ["_id": m_id, "name": m_name, "zip": m_zip, "timeZone": m_timeZone, "owner": m_owner]
                                }
                            }
                            
                            self.modelChanged()
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
    
    func modelChanged() {
        if self.defaults.stringForKey(Constants.kDefaultsSelectedDeviceId) == nil {
            let defaultDevice = self.devices.keys.first
            self.defaults.setObject(defaultDevice, forKey: Constants.kDefaultsSelectedDeviceId)
        }
        
        setSelectedDeviceTitle()
    }
    
    func setSelectedDeviceTitle() {
        let defaultDevice = self.defaults.stringForKey(Constants.kDefaultsSelectedDeviceId)!
        if let m_device = self.devices[defaultDevice] {
            if let m_name = m_device["name"] as? String {
                self.selectedDeviceLabel.text = m_name
                self.selectedDeviceLabel.sizeToFit()
            }
        }
    }
    
    func showSelectDevice() {
        self.performSegueWithIdentifier("showSelectDevice", sender: self)
    }
}

