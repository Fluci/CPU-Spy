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
        noteCenter.postNotificationName(msgKey, object: nil)
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
