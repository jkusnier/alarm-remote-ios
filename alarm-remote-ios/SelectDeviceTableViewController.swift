//
//  SelectDeviceTableViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/27/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit

class SelectDeviceTableViewController: UITableViewController {
    
    var presentingView:ViewController?
    
    var deviceKeys:[String]?
    var devices:[String: [String: AnyObject?]]? {
        didSet {
            if let keys = self.devices?.keys.array {
                self.deviceKeys = sorted(keys, { (s1: String, s2: String) -> Bool in
                    if let name1 = self.devices?[s1]?["name"] as? String {
                        if let name2 = self.devices?[s2]?["name"] as? String {
                            return name1 < name2
                        }
                    }
                    return s1 < s2 // fall back to just the key name
                })
            }
        }
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        self.tableView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceKeys != nil ? self.deviceKeys!.count : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        if let key = self.deviceKeys?[indexPath.row] {
            if let name = self.devices?[key]?["name"]? as? String {
                cell.textLabel?.text = name
            }
            
            if self.defaults.stringForKey(Constants.kDefaultsSelectedDeviceId) == key {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let key = self.deviceKeys?[indexPath.row] {
            self.defaults.setObject(key, forKey: Constants.kDefaultsSelectedDeviceId)
        }
        
        if self.presentingView != nil {
            self.presentingView!.dismissAuthSettings()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
