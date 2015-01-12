//
//  EditAlarmTableViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 1/8/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit

class EditAlarmTableViewController: UITableViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    @IBOutlet weak var sundayCell: UITableViewCell!
    @IBOutlet weak var mondayCell: UITableViewCell!
    @IBOutlet weak var tuesdayCell: UITableViewCell!
    @IBOutlet weak var wednesdayCell: UITableViewCell!
    @IBOutlet weak var thursdayCell: UITableViewCell!
    @IBOutlet weak var fridayCell: UITableViewCell!
    @IBOutlet weak var saturdayCell: UITableViewCell!
    
    var alarm: [String: AnyObject?]? {
        didSet {
            self.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadData()
        
        return super.viewWillAppear(animated)
    }
    
    private func reloadData() {
        if self.isViewLoaded() {
            let deviceName = self.alarm?["name"] as? String
            self.nameText.text = deviceName
            
            if let dayOfWeek = self.alarm?["dayOfWeek"] as? [Int] {
                self.sundayCell.accessoryType = UITableViewCellAccessoryType.None
                self.mondayCell.accessoryType = UITableViewCellAccessoryType.None
                self.tuesdayCell.accessoryType = UITableViewCellAccessoryType.None
                self.wednesdayCell.accessoryType = UITableViewCellAccessoryType.None
                self.thursdayCell.accessoryType = UITableViewCellAccessoryType.None
                self.fridayCell.accessoryType = UITableViewCellAccessoryType.None
                self.saturdayCell.accessoryType = UITableViewCellAccessoryType.None
                
                for day in dayOfWeek {
                    switch day {
                    case 1:
                        self.sundayCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    case 2:
                        self.mondayCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    case 3:
                        self.tuesdayCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    case 4:
                        self.wednesdayCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    case 5:
                        self.thursdayCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    case 6:
                        self.fridayCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    case 7:
                        self.saturdayCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    default:
                        println("Invalid Day")
                    }
                }
            }
        }
    }
}
