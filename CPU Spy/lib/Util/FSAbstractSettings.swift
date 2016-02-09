//
//  FSSettings.swift
//  CPU Spy
//
//  Created by Felice Serena on 25.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

/** 
 Allows to uniformly configure setting properties.
 Every update triggers a Notification with the corresponding msgKey.
 The setKey is used as key for the storage in NSUserDefaults.
 An inheriting class must implement initValues using getSetDefault.
 The initialization value of a member is ignored this way.
 */

public class FSAbstractSettings {
    public var userDefaults: NSUserDefaults
    public var noteCenter: NSNotificationCenter

    public var undoManager: NSUndoManager?

    /// should be called in didSet
    func update<T: Equatable, TargetType: AnyObject>(
        newValue: T,
        oldValue: T,
        setKey: String,
        msgKey: String,
        undoTarget: TargetType?,
        undoAction: TargetType -> ()
        ) {
            if oldValue == newValue {
                return
            }
            let obj = newValue as? AnyObject
            if obj == nil {
                NSLog("%@", "Couldn't cast value \"\(newValue)\" to AnyObject, setKey: \(setKey), msgKey: \(msgKey)")
            }
            userDefaults.setObject(obj, forKey: setKey)
            noteCenter.postNotificationName(msgKey, object: nil)
            if let target = undoTarget {
                undoManager?.registerUndoWithTarget(target, handler: undoAction)
            }
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
            var there = userDefaults.objectForKey(setKey) as? T
            if there == nil || !validityCheck(there!) {
                userDefaults.setObject(obj, forKey: setKey)
                there = defaultValue
            }
            debugPrint("loaded setting \(setKey): \(there!)")
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
