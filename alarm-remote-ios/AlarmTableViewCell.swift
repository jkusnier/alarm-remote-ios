//
//  AlarmTableViewCell.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/28/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!

    var statusSwitch: UISwitch!
    var alarm: [String: AnyObject?]?
    
    let api = APIController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusSwitch = UISwitch()
        self.statusSwitch.addTarget(self, action: "alarmStatusChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.accessoryView = self.statusSwitch
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func alarmStatusChanged(sender: UISwitch!) {
        if let alarm = self.alarm {
            if let deviceId = alarm["deviceId"] as? String {
                if let alarmId = alarm["_id"] as? String {
                    api.setAlarmStatus(deviceId: deviceId, alarmId: alarmId, alarmStatus: self.statusSwitch.on,
                        failure: {error in
                            self.statusSwitch.on = !self.statusSwitch.on
                        },
                        success: {
                            self.alarm!["status"] = self.statusSwitch.on
                    })
                }
            }
        }
    }
}
