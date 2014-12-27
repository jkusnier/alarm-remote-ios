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
            if let keys = self.devices?.keys {
                self.deviceKeys = keys.array
            }
            // TODO sort the keys based on the name value
        }
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
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
