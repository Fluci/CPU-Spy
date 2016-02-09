//
//  AppState.swift
//  CPU Spy
//
//  Created by Felice Serena on 28.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

/**
    This singleton tries to solve the problem of propagating value changes through the 
    application.
    These are temporary values, they are not stored on disk and not loaded at start up.
*/


class AppState: FSAbstractAppState {

    let msgRunModeChanged = "RUN_MODE_CHANGED"
    var runMode: RunMode = .Foreground {
        didSet {
            update(
                runMode,
                oldValue: oldValue,
                msgKey: msgRunModeChanged
            )
        }
    }

    let msgPowerSourceChanged = "POWER_SOURCE_CHANGED"
    var powerSource: PowerSource = .Battery {
        didSet {
            update(
                powerSource,
                oldValue: oldValue,
                msgKey: msgPowerSourceChanged
            )
        }
    }

    override func initValues() {
        runMode = .Foreground
        powerSource = .Battery
    }

}
