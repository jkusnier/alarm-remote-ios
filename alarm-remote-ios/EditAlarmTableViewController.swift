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
    @IBOutlet weak var statusSwitch: UISwitch!
    
    @IBOutlet weak var sundayCell: UITableViewCell!
    @IBOutlet weak var mondayCell: UITableViewCell!
    @IBOutlet weak var tuesdayCell: UITableViewCell!
    @IBOutlet weak var wednesdayCell: UITableViewCell!
    @IBOutlet weak var thursdayCell: UITableViewCell!
    @IBOutlet weak var fridayCell: UITableViewCell!
    @IBOutlet weak var saturdayCell: UITableViewCell!
    
    @IBOutlet weak var timeText: UITextField!

    var alarm: [String: AnyObject?]? {
        didSet {
            self.reloadData()
        }
    }
    
    let api = APIController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "Save", style: .Bordered, target: self, action: "saveAlarm")
        self.navigationItem.rightBarButtonItem = saveButton

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
            if let alarm = self.alarm {
                let f_alarm = api.formatAlarmForMainCell(alarm)
            
                let deviceName = alarm["name"] as? String
                self.nameText.text = deviceName
                
                let alarmTime = f_alarm["time"] as? String
                self.timeText.text = alarmTime
                
                if let alarmStatus = alarm["status"] as? Bool {
                    self.statusSwitch.on = alarmStatus
                } else {
                    self.statusSwitch.on = false
                }
                
                if let dayOfWeek = alarm["dayOfWeek"] as? [Int] {
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
    
    @IBAction func datepicker(sender: UITextField) {
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Time
        sender.inputView = datePickerView
        
        let d = NSDate(timeString: self.timeText.text)
        datePickerView.setDate(d, animated: false)
        
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        self.timeText.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func saveAlarm() {
        println("Save Alarm")
        
        let name = self.nameText.text
        let time = self.timeText.text // FIXME this needs to convert to int value of minutes
        let timeParts = time.componentsSeparatedByString(":")
        var timeInt:Int?
        if let hours = timeParts.first?.toInt() {
            if let minuteParts = timeParts.last?.componentsSeparatedByString(" ") {
                if let minutes = minuteParts.first?.toInt() {
                    var actualHours = minuteParts.last == "PM" ? hours + 12 : hours
                    timeInt = (actualHours * 60) + minutes
                }
            }
        }
        let status = self.statusSwitch.on
        var dayOfWeek: [Int]? = [Int]()
        
        if self.sundayCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            dayOfWeek?.append(1)
        }
        if self.mondayCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            dayOfWeek?.append(2)
        }
        if self.tuesdayCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            dayOfWeek?.append(3)
        }
        if self.wednesdayCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            dayOfWeek?.append(4)
        }
        if self.thursdayCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            dayOfWeek?.append(5)
        }
        if self.fridayCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            dayOfWeek?.append(6)
        }
        if self.saturdayCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            dayOfWeek?.append(7)
        }
        
        println("Name: \(name)")
        println("Time: \(time)")
        println("Time Int: \(timeInt)")
        println("Status: \(status)")
        println("Days: \(dayOfWeek)")
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryType.Checkmark ? UITableViewCellAccessoryType.None : UITableViewCellAccessoryType.Checkmark
            }
        }
    }
}
