//
//  APIController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/29/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import Foundation
import PKHUD

class APIController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let authUrl:String = "http://api.weecode.com/alarm/v1/users"
    
    func updateDevices(failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: ([String: [String: AnyObject?]] -> ())? = nil) {
        if succeed == nil { return }
        
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        let accessToken:NSString = defaults.stringForKey(Constants.kDefaultsAccessTokenKey)!
        let devicesUrl = "http://api.weecode.com/alarm/v1/devices?access_token=\(accessToken)"
        
        var request = NSMutableURLRequest(URL: NSURL(string: devicesUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                HUDController.sharedController.hide()

                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        var error: NSError?
                        let jsonArr:NSArray? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as? NSArray
                        
                        if error != nil || jsonArr == nil {
                            fail!(error)
                        } else {
                            var devices = [String: [String: AnyObject?]]()
                            
                            for item in jsonArr! {
                                if let dict = item as? NSDictionary {
                                    let m_id = dict.valueForKey("_id") as? String
                                    let m_name = dict.valueForKey("name") as? String
                                    let m_zip = dict.valueForKey("zip") as? Int
                                    let m_timeZone = dict.valueForKey("timeZone") as? Int
                                    let m_owner = dict.valueForKey("owner") as? String
                                    
                                    devices[m_id!] = ["_id": m_id, "name": m_name, "zip": m_zip, "timeZone": m_timeZone, "owner": m_owner]
                                }
                            }
                            succeed!(devices)
                        }
                    } else {
                        fail!(error)
                    }
                } else {
                    fail!(error)
                }
            })
        })
    }
    
    func getDeviceAlarms(failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: ([String: [String: AnyObject?]] -> ())? = nil) {
        if succeed == nil { return }
        
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        let deviceId = self.defaults.stringForKey(Constants.kDefaultsSelectedDeviceId)!
        let accessToken:NSString = defaults.stringForKey(Constants.kDefaultsAccessTokenKey)!
        let alarmsUrl = "http://api.weecode.com/alarm/v1/devices/\(deviceId)/alarms?access_token=\(accessToken)"
        
        var request = NSMutableURLRequest(URL: NSURL(string: alarmsUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                HUDController.sharedController.hide()
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        var error: NSError?
                        let jsonArr:NSArray? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as? NSArray
                        
                        if error != nil || jsonArr == nil {
                            fail!(error)
                        } else {
                            var alarms = [String: [String: AnyObject?]]()
                            
                            for item in jsonArr! {
                                if let dict = item as? NSDictionary {
                                    let m_id = dict.valueForKey("_id") as? String
                                    let m_dayOfWeek = dict.valueForKey("dayOfWeek") as? [Int]
                                    let m_name = dict.valueForKey("name") as? String
                                    let m_status = dict.valueForKey("status") as? Bool
                                    let m_time = dict.valueForKey("time") as? Int
                                    
                                    alarms[m_id!] = ["_id": m_id, "dayOfWeek": m_dayOfWeek, "name": m_name, "status": m_status, "time": m_time]
                                }
                            }
                            
                            succeed!(alarms)
                        }
                    } else {
                        fail!(error)
                    }
                } else {
                    fail!(error)
                }
            })
        })
    }
    
    func getAccessToken(userName: String, password: String, failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: (String -> ())? = nil) {
        if succeed == nil { return }
        
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        var request = NSMutableURLRequest(URL: NSURL(string: authUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        
        let jsonString = "{\"user_id\":\"\(userName)\", \"password\":\"\(password)\"}"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                HUDController.sharedController.hide()
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        var error: NSError?
                        let jsonDict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as NSDictionary
                        if let accessToken = jsonDict.valueForKey("accessToken") as? String {
                            self.defaults.setValue(userName, forKey: Constants.kDefaultsUsernameKey)
                            
                            succeed!(accessToken)
                        }
                    } else {
                        fail!(error)
                    }
                } else {
                    fail!(error)
                }
            })
        })
    }
    
    func testAccessToken(userName: String, accessToken: String, failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
        
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
                        
                        if (userName == jsonDict.valueForKey("_id") as? String) {
                            self.defaults.setValue(accessToken, forKey: Constants.kDefaultsAccessTokenKey)
                            
                            succeed!()
                        } else {
                            fail!(error)
                        }
                    }
                })
            });
        }
    }
}