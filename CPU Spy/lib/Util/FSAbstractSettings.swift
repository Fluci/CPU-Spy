//
//  FSSettings.swift
//  CPU Spy
//
//  Created by Felice Serena on 25.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

public class FSAbstractSettings {
    public let userDefaults: NSUserDefaults
    public let noteCenter: NSNotificationCenter

    /// should be called in didSet
    func update<T: Equatable>(newValue: T, oldValue: T, setKey: String, msgKey: String) {
        if oldValue == newValue {
            return
        }
        let obj = newValue as? AnyObject
        if obj == nil {
            NSLog("%@", "Couldn't cast value \"\(newValue)\" to AnyObject, setKey: \(setKey), msgKey: \(msgKey)")
        }
        userDefaults.setObject(obj, forKey: setKey)
        noteCenter.postNotificationName(msgKey, object: obj)
    }
    /**
        Tries to read the value in userDefaults, falls back to defaultValue if this fails.
        Reading the userDefault value fails iff
        * it's not set or
        * validityCheck(value) returns false.

        - parameter defaultValue: value to set if no defaultSettings
            are in place or validityCheck returns false
        - parameter setKey: key used by *userDefaults*
        - parameter validityCheck: Shall return true iff passed value is valid and can be used.
        - returns: The value now stored in userDefaults.
     */
    func getSetDefault<T>(
        defaultValue: T,
        setKey: String,
        validityCheck: T -> Bool = {_ in true}) -> T {
            let obj = defaultValue as? AnyObject
            if obj == nil {
                NSLog("%@", "Value \(defaultValue) for key \(setKey) not convertible to AnyObject.")
            }
            let there = userDefaults.objectForKey(setKey) as? T
            if there == nil || !validityCheck(there!) {
                userDefaults.setObject(obj, forKey: setKey)
                return defaultValue
            }
            return there!
    }

    init(someUserDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults(),
        someNotificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()) {
        userDefaults = someUserDefaults
        noteCenter = someNotificationCenter
        initValues()
    }

    func initValues() {
        preconditionFailure("initValues must be overwritten")
    }
}
