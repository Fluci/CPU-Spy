//
//  Settings.swift
//  CPU Spy
//
//  Created by Felice Serena on 25.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

let settings = Settings()

public class Settings: FSAbstractSettings {
    let settingSampleIntervalForeground = "SAMPLE_INTERVAL_FOREGROUND"
    let settingSampleIntervalBackground = "SAMPLE_INTERVAL_BACKGROUND"
    let settingSampleIntervalHidden     = "SAMPLE_INTERVAL_HIDDEN"

    let msgNewSampleIntervalForeground = "NEW_SAMPLE_INTERVAL_FOREGROUND"
    let msgNewSampleIntervalBackground = "NEW_SAMPLE_INTERVAL_BACKGROUND"
    let msgNewSampleIntervalHidden     = "NEW_SAMPLE_INTERVAL_HIDDEN"

    var sampleIntervalForeground: Double = 0 {
        didSet {
            update(
                sampleIntervalForeground,
                oldValue: oldValue,
                setKey: settingSampleIntervalForeground,
                msgKey: msgNewSampleIntervalForeground
            )
        }
    }
    var sampleIntervalBackground: Double = 0 {
        didSet {
            update(
                sampleIntervalBackground,
                oldValue: oldValue,
                setKey: settingSampleIntervalBackground,
                msgKey: msgNewSampleIntervalBackground
            )
        }
    }
    var sampleIntervalHidden: Double = 0 {
        didSet {
            update(
                sampleIntervalHidden,
                oldValue: oldValue,
                setKey: settingSampleIntervalHidden,
                msgKey: msgNewSampleIntervalHidden
            )
        }
    }

    override func initValues() {
        sampleIntervalForeground = getSetDefault(1.0, setKey: settingSampleIntervalForeground) {$0 > 0}
        sampleIntervalBackground = getSetDefault(5.0, setKey: settingSampleIntervalBackground) {$0 > 0}
        sampleIntervalHidden = getSetDefault(10.0, setKey: settingSampleIntervalHidden) {$0 > 0}
    }
}
