//
//  FSAbstractAppState.swift
//  CPU Spy
//
//  Created by Felice Serena on 28.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


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

    func initValues() {
        preconditionFailure("initValues must be overwritten")
    }
}
