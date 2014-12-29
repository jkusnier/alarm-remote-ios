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
    
    func updateDevices(failure fail : (NSError -> ())? = { error in println(error) }, success succeed: ([String: [String: AnyObject?]] -> ())? = nil) {
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
                            fail!(error!)
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
                        fail!(error!)
                    }
                } else {
                    fail!(error!)
                }
            })
        })
    }
    
    func getDeviceAlarms(failure fail : (NSError -> ())? = { error in println(error) }, success succeed: ([String: [String: AnyObject?]] -> ())? = nil) {
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
                            fail!(error!)
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
                        fail!(error!)
                    }
                } else {
                    fail!(error!)
                }
            })
        })
    }
}