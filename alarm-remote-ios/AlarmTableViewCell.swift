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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusSwitch = UISwitch()
        self.accessoryView = self.statusSwitch
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
