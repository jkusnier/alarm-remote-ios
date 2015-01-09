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

    @IBOutlet weak var bottomToolbar: UIToolbar!

    @IBOutlet weak var tableView: UITableView!
    
    var editButton: UIBarButtonItem?
    let editTitles = [Constants.kEditName, Constants.kDoneName]
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let switchButton = UIBarButtonItem(title: Constants.kDeviceSelectionButtonName, style: .Bordered, target: self, action: "showSelectDevice")
        self.editButton = UIBarButtonItem(title: self.editTitles.first, style: .Bordered, target: self, action: "toggleEditingMode")

        self.navigationItem.leftBarButtonItem = switchButton
        self.navigationItem.rightBarButtonItem = self.editButton
        
        self.tableView.allowsSelection = false
        self.tableView.allowsSelectionDuringEditing = true
        
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
        if let identifier = segue.identifier {
            if contains(["showAuth", "showAuthSettings"], identifier) {
                if let destView = segue.destinationViewController as? AuthViewController {
                    destView.presentingView = self
                }
            } else if (identifier == "showSelectDevice") {
                if let destView = segue.destinationViewController as? SelectDeviceTableViewController {
                    destView.presentingView = self
                }
            } else if (identifier == "showAlarmEditor") {
                if let destView = segue.destinationViewController as? EditAlarmTableViewController {
                    if let cell = sender as? AlarmTableViewCell {
                        destView.alarm = cell.alarm
                    }
                }
            }
        }
    }
    
    func dismissAuthSettings() {
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

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissDeviceSelection(devices: [String: [String: AnyObject?]]?) {
        if let devices = devices {
            self.devices = devices
        }
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
                self.title = m_name
            }
        }
    }

    func showSelectDevice() {
        self.performSegueWithIdentifier("showSelectDevice", sender: self)
    }
    
    func toggleEditingMode() {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
        self.editButton?.title = self.tableView.editing ? self.editTitles.last : self.editTitles.first
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
                m_cell.alarm = m_alarm
                let f_alarm = api.formatAlarmForMainCell(m_alarm)
                
                m_cell.nameLabel.text = f_alarm["name"] as? String
                m_cell.timeLabel.text = f_alarm["time"] as? String
                if let m_status = f_alarm["status"] as? Bool {
                    m_cell.statusSwitch.on = m_status
                } else {
                    m_cell.statusSwitch.on = false
                }
                m_cell.dayOfWeekLabel.text = f_alarm["dayOfWeek"] as? String
            }

            cell = m_cell
        }
        
        cell?.editingAccessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Prevent the selection from sticking
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

