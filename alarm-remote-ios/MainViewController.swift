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
            }
        }
    }
    
    func dismissAuthSettings() {
        self.modelChanged()
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
        
        return cell!
    }
}

