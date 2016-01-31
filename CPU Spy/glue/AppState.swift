//
//  AppState.swift
//  CPU Spy
//
//  Created by Felice Serena on 28.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

let appState = AppState()

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

    override func initValues() {
        runMode = .Foreground
    }

}
