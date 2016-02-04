//
//  FSAbstractAppState.swift
//  CPU Spy
//
//  Created by Felice Serena on 28.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

/**
 Allows to propagate value changes through the application and efficient value querying.
 An inheriting class should create a member for each value, providing an associated msgKey
 used in NSNotificationCenter. Triggering the propagation should be implemented by
 calling update() in the members didSet{} observer.
 The initial values can be set either in the member initialization or by overriding
 initValues.
*/

public class FSAbstractAppState {
    internal let noteCenter: NSNotificationCenter

    /// should be called in didSet
    func update<T: Equatable>(newValue: T, oldValue: T, msgKey: String) {
        if oldValue == newValue {
            return
        }
        let obj = newValue as? AnyObject
        noteCenter.postNotificationName(msgKey, object: obj)
    }

    init(
        someNotificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()) {
        noteCenter = someNotificationCenter
        initValues()
    }
    /// can be implemented by child, called after initalization of object
    func initValues() {
        // placeholder
    }
}
