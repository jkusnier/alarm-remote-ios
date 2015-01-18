//
//  DateTimeExtension.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 1/18/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation

extension NSDate {
    convenience
    init(timeString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "h:mm a"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(timeString)
        self.init(timeInterval:0, sinceDate:d!)
    }    
}
