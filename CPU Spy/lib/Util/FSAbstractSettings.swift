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
    func update(newValue: Double, oldValue: Double, setKey: String, msgKey: String) {
        if oldValue == newValue {
            return
        }
        userDefaults.setDouble(newValue, forKey: setKey)
        noteCenter.postNotificationName(msgKey, object: newValue)
    }
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
    func getSetDefault(
        defaultValue: Double,
        setKey: String,
        validityCheck: Double -> Bool = {true || $0 == 0.0}) -> Double {
        if userDefaults.objectForKey(setKey) == nil {
            userDefaults.setDouble(defaultValue, forKey: setKey)
            return defaultValue
        }
        let there = userDefaults.doubleForKey(setKey)
        if !validityCheck(there) {
            userDefaults.setDouble(defaultValue, forKey: setKey)
            return defaultValue
        }
        return there
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
