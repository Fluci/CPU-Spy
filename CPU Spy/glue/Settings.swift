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
    let msgNewSampleIntervalForeground = "NEW_SAMPLE_INTERVAL_FOREGROUND"
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

    let settingSampleIntervalBackground = "SAMPLE_INTERVAL_BACKGROUND"
    let msgNewSampleIntervalBackground = "NEW_SAMPLE_INTERVAL_BACKGROUND"
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

    let settingSampleIntervalHidden = "SAMPLE_INTERVAL_HIDDEN"
    let msgNewSampleIntervalHidden  = "NEW_SAMPLE_INTERVAL_HIDDEN"
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

    let settingRefreshForeground = "REFRESH_FOREGROUND"
    let msgNewRefreshForeground  = "NEW_REFRESH_FOREGROUND"
    var refreshForeground = true {
        didSet {
            update(
                refreshForeground,
                oldValue: oldValue,
                setKey: settingRefreshForeground,
                msgKey: msgNewRefreshForeground
            )
        }
    }

    let settingRefreshBackground = "REFRESH_BACKGROUND"
    let msgNewRefreshBackground  = "NEW_REFRESH_BACKGROUND"
    var refreshBackground = true {
        didSet {
            update(
                refreshBackground,
                oldValue: oldValue,
                setKey: settingRefreshBackground,
                msgKey: msgNewRefreshBackground
            )
        }
    }

    let settingRefreshHidden = "REFRESH_HIDDEN"
    let msgNewRefreshHidden  = "NEW_REFRESH_HIDDEN"
    var refreshHidden = true {
        didSet {
            update(
                refreshHidden,
                oldValue: oldValue,
                setKey: settingRefreshHidden,
                msgKey: msgNewRefreshHidden
            )
        }
    }

    let settingMaxTableEntries = "MAX_TABLE_ENTRIES"
    let msgNewMaxTableEntries  = "NEW_MAX_TABLE_ENTRIES"
    var maxTableEntries: Int = 0 {
        didSet {
            update(
                maxTableEntries,
                oldValue: oldValue,
                setKey: settingMaxTableEntries,
                msgKey: msgNewMaxTableEntries
            )
        }
    }
    let settingIconSamples = "ICON_SAMPLES"
    let msgNewIconSamples  = "NEW_ICON_SAMPLES"
    var iconSamples: Int = 0 {
        didSet {
            update(
                iconSamples,
                oldValue: oldValue,
                setKey: settingIconSamples,
                msgKey: msgNewIconSamples
            )
        }
    }
    let settingIconProcesses = "ICON_PROCESSES"
    let msgNewIconProcesses  = "NEW_ICON_PROCESSES"
    var iconProcesses: Int = 0 {
        didSet {
            update(
                iconProcesses,
                oldValue: oldValue,
                setKey: settingIconProcesses,
                msgKey: msgNewIconProcesses
            )
        }
    }

    override func initValues() {
        sampleIntervalForeground = getSetDefault(1.0,
            setKey: settingSampleIntervalForeground) {$0 > 0}
        sampleIntervalBackground = getSetDefault(5.0,
            setKey: settingSampleIntervalBackground) {$0 > 0}
        sampleIntervalHidden = getSetDefault(10.0,
            setKey: settingSampleIntervalHidden) {$0 > 0}

        refreshForeground = getSetDefault(true, setKey: settingRefreshForeground)
        refreshBackground = getSetDefault(false, setKey: settingRefreshBackground)
        refreshHidden     = getSetDefault(false, setKey: settingRefreshHidden)

        maxTableEntries = getSetDefault(0, setKey: settingMaxTableEntries) {$0 >= -1}
        iconSamples     = getSetDefault(64, setKey: settingIconSamples) {$0 >= -1}
        iconProcesses   = getSetDefault(7, setKey: settingIconProcesses) {$0 >= -1}
    }
}
