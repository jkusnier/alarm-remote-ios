//
//  ViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/24/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import PKHUD

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var topToolbarConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomToolbar: UIToolbar!

    @IBOutlet weak var tableView: UITableView!
    
    let api = APIController()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var devices = [String: [String: AnyObject?]]()
    var alarmKeys: [String] = [String]()
    var alarms: [String: [String: AnyObject?]]? {
        didSet {
            if let keys = self.alarms?.keys.array {
                self.alarmKeys = sorted(keys, { (s1: String, s2: String) -> Bool in
                    if let time1 = self.alarms?[s1]?["time"] as? Int {
                        if let time2 = self.alarms?[s2]?["time"] as? Int {
                            return time1 < time2
                        }
                    }
                    return s1 < s2 // fall back to just the key name
                })
            } else {
                self.alarmKeys = [String]()
            }
        }
    }
    
    let selectedDeviceLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topToolbarConstraint.constant = UIApplication.sharedApplication().statusBarFrame.height
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let switchButton = UIBarButtonItem(title: "Switch", style: .Bordered, target: self, action: "showSelectDevice")
        let editButton = UIBarButtonItem(title: "Edit", style: .Bordered, target: nil, action: nil)
        
        self.topToolbar.items = [switchButton, flexibleSpace, UIBarButtonItem(customView: self.selectedDeviceLabel), flexibleSpace, editButton]
        
        if defaults.stringForKey(Constants.kDefaultsAccessTokenKey) != nil {
            api.updateDevices(
                failure: { error in
                    let alert = UIAlertController(title: "Error", message: "Error Retrieving Data", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                },
                success: { devices in
                    self.devices = devices
                    self.modelChanged()
            })
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

    func modelChanged() {
        if self.defaults.stringForKey(Constants.kDefaultsSelectedDeviceId) == nil {
            let defaultDevice = self.devices.keys.first
            self.defaults.setObject(defaultDevice, forKey: Constants.kDefaultsSelectedDeviceId)
        }
        
        setSelectedDeviceTitle()
        api.getDeviceAlarms(
            failure: { error in
                let alert = UIAlertController(title: "Error", message: "Error Retrieving Data", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            },
            success: { alarms in
                self.alarms = alarms
                self.tableView.reloadData()
        })
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
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarmKeys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let m_alarmId = self.alarmKeys[indexPath.row]
        
        if let m_cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? AlarmTableViewCell {
            if let m_alarm = self.alarms?[m_alarmId] {
                m_cell.nameLabel.text = m_alarm["name"] as? String
                if let m_time = m_alarm["time"] as? Int {
                    let hour = m_time / 60
                    let minute = m_time % 60
                    let am_pm = m_time >= 12 ? "PM" : "AM"
                    
                    let minute_prefix = (minute < 10) ? "0" : ""
                    let m_hour = (hour > 12) ? hour - 12 : (hour == 0) ? 12 : hour
                    
                    m_cell.timeLabel.text = "\(m_hour):\(minute_prefix)\(minute) \(am_pm)"
                } else {
                    m_cell.timeLabel.text = ""
                }
                if let m_status = m_alarm["status"] as? Bool {
                    m_cell.statusSwitch.on = m_status
                } else {
                    m_cell.statusSwitch.on = false
                }
                if let m_dayOfWeek = m_alarm["dayOfWeek"] as? [Int] {
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

                    m_cell.dayOfWeekLabel.text = m_reduced
                }
            }
            
            cell = m_cell
        }
        
        return cell!
    }
}

