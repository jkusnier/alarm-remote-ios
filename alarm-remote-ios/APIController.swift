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
    
    func updateDevices(accessToken t: String? = "", failure fail: (NSError? -> ())? = { error in println(error) }, success succeed: ([String: [String: AnyObject?]] -> ())? = nil) {
        if succeed == nil { return }
        
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        let accessToken:NSString = t!.isEmpty ? defaults.stringForKey(Constants.kDefaultsAccessTokenKey)! : t!
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
    
    func getDeviceAlarms(accessToken t: String? = "", deviceId d: String? = "", failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: ([String: [String: AnyObject?]] -> ())? = nil) {
        if succeed == nil { return }
        
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        let deviceId = d!.isEmpty ? self.defaults.stringForKey(Constants.kDefaultsSelectedDeviceId)! : d!
        let accessToken:NSString = t!.isEmpty ? defaults.stringForKey(Constants.kDefaultsAccessTokenKey)! : t!
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
                                    let m_deviceId = dict.valueForKey("deviceId") as? String
                                    let m_dayOfWeek = dict.valueForKey("dayOfWeek") as? [Int]
                                    let m_name = dict.valueForKey("name") as? String
                                    let m_status = dict.valueForKey("status") as? Bool
                                    let m_time = dict.valueForKey("time") as? Int
                                    
                                    alarms[m_id!] = ["_id": m_id, "deviceId": m_deviceId, "dayOfWeek": m_dayOfWeek, "name": m_name, "status": m_status, "time": m_time]
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
    
    func setAlarmStatus(accessToken t: String? = "", deviceId d: String? = "", alarmId a: String? = "", alarmStatus: Bool, failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
        if succeed == nil { return }
        
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        let accessToken:NSString = t!.isEmpty ? defaults.stringForKey(Constants.kDefaultsAccessTokenKey)! : t!
        let deviceId:String = d!
        let alarmId:String = a!
        let alarmsUrl = "http://api.weecode.com/alarm/v1/devices/\(deviceId)/alarms/\(alarmId)?access_token=\(accessToken)"
        
        var request = NSMutableURLRequest(URL: NSURL(string: alarmsUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        
        let jsonString = "{\"status\":\(alarmStatus)}"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                HUDController.sharedController.hide()
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        succeed!()
                    } else {
                        fail!(error)
                    }
                } else {
                    fail!(error)
                }
            })
        })
    }
    
    func updateAlarm(accessToken t: String? = "", deviceId d: String? = "", alarmId a: String? = "", alarmName: String?, alarmTime: Int?, alarmStatus: Bool?, alarmDayOfWeek: [Int]?, failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
        
        if succeed == nil { return }
        
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        let accessToken:NSString = t!.isEmpty ? defaults.stringForKey(Constants.kDefaultsAccessTokenKey)! : t!
        let deviceId:String = d!
        let alarmId:String = a!
        let alarmsUrl = "http://api.weecode.com/alarm/v1/devices/\(deviceId)/alarms/\(alarmId)?access_token=\(accessToken)"
        
        var request = NSMutableURLRequest(URL: NSURL(string: alarmsUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        
        var jsonString = "{"
        var jsonContent:[String] = [String]()
        if let alarmName = alarmName { jsonContent.append("\"name\":\"\(alarmName)\"") }
        if let alarmTime = alarmTime { jsonContent.append("\"time\":\(alarmTime)") }
        if let alarmStatus = alarmStatus { jsonContent.append("\"status\":\(alarmStatus)") }
        if let alarmDayOfWeek = alarmDayOfWeek {
            let days = ",".join(alarmDayOfWeek.map {$0.description})
            jsonContent.append("\"dayOfWeek\":[\(days)]")
        }
        jsonString += ",".join(jsonContent)
        jsonString += "}"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                HUDController.sharedController.hide()
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        succeed!()
                    } else {
                        fail!(error)
                    }
                } else {
                    fail!(error)
                }
            })
        })
    }
    
    func addAlarm(accessToken t: String? = "", deviceId d: String? = "", alarmName: String?, alarmTime: Int?, alarmStatus: Bool?, alarmDayOfWeek: [Int]?, failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
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
    
    func formatAlarmForMainCell(alarm: [String: AnyObject?]) -> [String: AnyObject?] {
        var result = [String: AnyObject?]()
        
        result["name"] = alarm["name"] as? String
        
        if let m_time = alarm["time"] as? Int {
            let hour = m_time / 60
            let minute = m_time % 60
            let am_pm = hour >= 12 ? "PM" : "AM"
                
            let minute_prefix = (minute < 10) ? "0" : ""
            let m_hour = (hour > 12) ? hour - 12 : (hour == 0) ? 12 : hour
                
            result["time"] = "\(m_hour):\(minute_prefix)\(minute) \(am_pm)"
        } else {
            result["time"] = ""
        }
        
        if let m_status = alarm["status"] as? Bool {
            result["status"] = m_status
        } else {
            result["status"] = false
        }
        
        if let m_dayOfWeek = alarm["dayOfWeek"] as? [Int] {
            let m2_dayOfWeek = sorted(m_dayOfWeek) // Order is likely, but not guaranteed
            let days = ["","Su","Mo","Tu","We","Th","Fr","Sa"] // 1 = Sunday, 7 = Saturday
                
            let dash = "-"
            var m_reduced = ""
            func appendDay(str: String, day: String) -> String {
                if day == dash {
                    if str.hasSuffix(dash) { return str } // We already have a dash
                    else { return str + dash } // Append the dash and return
                } else {
                    return str + (!str.hasSuffix(dash) ? "," : "")  + day // Append a comma if needed and the day
                }
            }
            // TODO, determine if a range crosses Sat / Sun and realign the array
            for (index, value) in enumerate(m_dayOfWeek) {
                if index == 0 {
                    m_reduced += days[value] // Just add the first value to the string
                } else {
                    let prev_val = m_dayOfWeek[index - 1] // Used to determine if we have a range
                    if index + 1 < m_dayOfWeek.count { // We're not at the end
                        let next_val = m_dayOfWeek[index + 1] // Used to determine if we have a range
                        if value == prev_val + 1 && value == next_val - 1 { // We have a range
                            m_reduced = appendDay(m_reduced, dash)
                        } else { // No range, append the day
                            m_reduced = appendDay(m_reduced, days[value])
                        }
                    } else { // At the end
                        m_reduced = appendDay(m_reduced, days[value])
                    }
                }
            }

            result["dayOfWeek"] = m_reduced
        }

        return result
    }
}