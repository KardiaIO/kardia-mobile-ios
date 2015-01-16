//
//  DateTimeHelpers.swift
//  KardiaApp
//
//  Created by Bernie Chu on 1/8/15.
//  Copyright (c) 2015 Kardia. All rights reserved.
//

import Foundation

// Converts default NSDate format to ISO 8601
public func ISOStringFromDate(date: NSDate) -> String {
    var dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    
    return dateFormatter.stringFromDate(date).stringByAppendingString("Z")
}

// Converts NSDate to human-readable string according to local format
public func TimestampFromDate(date: NSDate) -> String {
    let style = NSDateFormatterStyle.LongStyle
    return NSDateFormatter.localizedStringFromDate(date, dateStyle: style, timeStyle: style)
}
