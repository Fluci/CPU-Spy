//
//  Settings.swift
//  CPU Spy
//
//  Created by Felice Serena on 25.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

/**
    This singleton tries to solve the problem of propagating value changes through the system.
    Additionally these properties are stored on the useres machine and reloaded at start up.
    Every change is stored immediatly.
*/


public class Settings: FSAbstractSettings {

    let settingPowerSource = "POWER_SOURCE"
    let msgNewPowerSource = "NEW_POWER_SOURCE"
    var powerSource: PowerSource = .AC {
        didSet {
            update(
                powerSource.rawValue,
                oldValue: oldValue.rawValue,
                setKey: settingPowerSource,
                msgKey: msgNewPowerSource,
                undoTarget: self,
                undoAction: { $0.powerSource = oldValue }
            )
        }
    }

    let settingSampleIntervalForegroundAC = "SAMPLE_INTERVAL_FOREGROUND_AC"
    let msgNewSampleIntervalForegroundAC = "NEW_SAMPLE_INTERVAL_FOREGROUND_AC"
    var sampleIntervalForegroundAC: Double = 0 {
        didSet {
            update(
                sampleIntervalForegroundAC,
                oldValue: oldValue,
                setKey: settingSampleIntervalForegroundAC,
                msgKey: msgNewSampleIntervalForegroundAC,
                undoTarget: self,
                undoAction: { $0.sampleIntervalForegroundAC = oldValue }
            )
        }
    }

    let settingSampleIntervalBackgroundAC = "SAMPLE_INTERVAL_BACKGROUND_AC"
    let msgNewSampleIntervalBackgroundAC = "NEW_SAMPLE_INTERVAL_BACKGROUND_AC"
    var sampleIntervalBackgroundAC: Double = 0 {
        didSet {
            update(
                sampleIntervalBackgroundAC,
                oldValue: oldValue,
                setKey: settingSampleIntervalBackgroundAC,
                msgKey: msgNewSampleIntervalBackgroundAC,
                undoTarget: self,
                undoAction: { $0.sampleIntervalBackgroundAC = oldValue }
            )
        }
    }

    let settingSampleIntervalHiddenAC = "SAMPLE_INTERVAL_HIDDEN_AC"
    let msgNewSampleIntervalHiddenAC  = "NEW_SAMPLE_INTERVAL_HIDDEN_AC"
    var sampleIntervalHiddenAC: Double = 0 {
        didSet {
            update(
                sampleIntervalHiddenAC,
                oldValue: oldValue,
                setKey: settingSampleIntervalHiddenAC,
                msgKey: msgNewSampleIntervalHiddenAC,
                undoTarget: self,
                undoAction: { $0.sampleIntervalHiddenAC = oldValue }
            )
        }
    }

    let settingRefreshForegroundAC = "REFRESH_FOREGROUND_AC"
    let msgNewRefreshForegroundAC  = "NEW_REFRESH_FOREGROUND_AC"
    var refreshForegroundAC = true {
        didSet {
            update(
                refreshForegroundAC,
                oldValue: oldValue,
                setKey: settingRefreshForegroundAC,
                msgKey: msgNewRefreshForegroundAC,
                undoTarget: self,
                undoAction: { $0.refreshForegroundAC = oldValue }
            )
        }
    }

    let settingRefreshBackgroundAC = "REFRESH_BACKGROUND_AC"
    let msgNewRefreshBackgroundAC  = "NEW_REFRESH_BACKGROUND_AC"
    var refreshBackgroundAC = true {
        didSet {
            update(
                refreshBackgroundAC,
                oldValue: oldValue,
                setKey: settingRefreshBackgroundAC,
                msgKey: msgNewRefreshBackgroundAC,
                undoTarget: self,
                undoAction: { $0.refreshBackgroundAC = oldValue }
            )
        }
    }

    let settingRefreshHiddenAC = "REFRESH_HIDDEN_AC"
    let msgNewRefreshHiddenAC  = "NEW_REFRESH_HIDDEN_AC"
    var refreshHiddenAC = true {
        didSet {
            update(
                refreshHiddenAC,
                oldValue: oldValue,
                setKey: settingRefreshHiddenAC,
                msgKey: msgNewRefreshHiddenAC,
                undoTarget: self,
                undoAction: { $0.refreshHiddenAC = oldValue }
            )
        }
    }


    let settingSampleIntervalForegroundBattery = "SAMPLE_INTERVAL_FOREGROUND_BATTERY"
    let msgNewSampleIntervalForegroundBattery = "NEW_SAMPLE_INTERVAL_FOREGROUND_BATTERY"
    var sampleIntervalForegroundBattery: Double = 0 {
        didSet {
            update(
                sampleIntervalForegroundAC,
                oldValue: oldValue,
                setKey: settingSampleIntervalForegroundAC,
                msgKey: msgNewSampleIntervalForegroundAC,
                undoTarget: self,
                undoAction: { $0.sampleIntervalForegroundBattery = oldValue }
            )
        }
    }

    let settingSampleIntervalBackgroundBattery = "SAMPLE_INTERVAL_BACKGROUND_BATTERY"
    let msgNewSampleIntervalBackgroundBattery = "NEW_SAMPLE_INTERVAL_BACKGROUND_BATTERY"
    var sampleIntervalBackgroundBattery: Double = 0 {
        didSet {
            update(
                sampleIntervalBackgroundAC,
                oldValue: oldValue,
                setKey: settingSampleIntervalBackgroundAC,
                msgKey: msgNewSampleIntervalBackgroundAC,
                undoTarget: self,
                undoAction: { $0.sampleIntervalBackgroundBattery = oldValue }
            )
        }
    }

    let settingSampleIntervalHiddenBattery = "SAMPLE_INTERVAL_HIDDEN_BATTERY"
    let msgNewSampleIntervalHiddenBattery  = "NEW_SAMPLE_INTERVAL_HIDDEN_BATTERY"
    var sampleIntervalHiddenBattery: Double = 0 {
        didSet {
            update(
                sampleIntervalHiddenAC,
                oldValue: oldValue,
                setKey: settingSampleIntervalHiddenAC,
                msgKey: msgNewSampleIntervalHiddenAC,
                undoTarget: self,
                undoAction: { $0.sampleIntervalHiddenBattery = oldValue }
            )
        }
    }

    let settingRefreshForegroundBattery = "REFRESH_FOREGROUND_BATTERY"
    let msgNewRefreshForegroundBattery  = "NEW_REFRESH_FOREGROUND_BATTERY"
    var refreshForegroundBattery = true {
        didSet {
            update(
                refreshForegroundBattery,
                oldValue: oldValue,
                setKey: settingRefreshForegroundBattery,
                msgKey: msgNewRefreshForegroundBattery,
                undoTarget: self,
                undoAction: { $0.refreshForegroundBattery = oldValue }
            )
        }
    }

    let settingRefreshBackgroundBattery = "REFRESH_BACKGROUND_BATTERY"
    let msgNewRefreshBackgroundBattery  = "NEW_REFRESH_BACKGROUND_BATTERY"
    var refreshBackgroundBattery = true {
        didSet {
            update(
                refreshBackgroundBattery,
                oldValue: oldValue,
                setKey: settingRefreshBackgroundBattery,
                msgKey: msgNewRefreshBackgroundBattery,
                undoTarget: self,
                undoAction: { $0.refreshBackgroundBattery = oldValue }
            )
        }
    }

    let settingRefreshHiddenBattery = "REFRESH_HIDDEN_BATTERY"
    let msgNewRefreshHiddenBattery  = "NEW_REFRESH_HIDDEN_BATTERY"
    var refreshHiddenBattery = true {
        didSet {
            update(
                refreshHiddenBattery,
                oldValue: oldValue,
                setKey: settingRefreshHiddenBattery,
                msgKey: msgNewRefreshHiddenBattery,
                undoTarget: self,
                undoAction: { $0.refreshHiddenBattery = oldValue }
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
                msgKey: msgNewMaxTableEntries,
                undoTarget: self,
                undoAction: { $0.maxTableEntries = oldValue }
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
                msgKey: msgNewIconSamples,
                undoTarget: self,
                undoAction: { $0.iconSamples = oldValue }
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
                msgKey: msgNewIconProcesses,
                undoTarget: self,
                undoAction: { $0.iconProcesses = oldValue }
            )
        }
    }

    override func initValues() {
        sampleIntervalForegroundAC = getSetDefault(1.0,
            setKey: settingSampleIntervalForegroundAC) {$0 > 0}
        sampleIntervalBackgroundAC = getSetDefault(5.0,
            setKey: settingSampleIntervalBackgroundAC) {$0 > 0}
        sampleIntervalHiddenAC = getSetDefault(10.0,
            setKey: settingSampleIntervalHiddenAC) {$0 > 0}

        sampleIntervalForegroundBattery = getSetDefault(1.0,
            setKey: settingSampleIntervalForegroundBattery) {$0 > 0}
        sampleIntervalBackgroundBattery = getSetDefault(5.0,
            setKey: settingSampleIntervalBackgroundBattery) {$0 > 0}
        sampleIntervalHiddenBattery = getSetDefault(10.0,
            setKey: settingSampleIntervalHiddenBattery) {$0 > 0}

        refreshForegroundAC = getSetDefault(true, setKey: settingRefreshForegroundAC)
        refreshBackgroundAC = getSetDefault(false, setKey: settingRefreshBackgroundAC)
        refreshHiddenAC     = getSetDefault(false, setKey: settingRefreshHiddenAC)

        refreshForegroundBattery = getSetDefault(true, setKey: settingRefreshForegroundBattery)
        refreshBackgroundBattery = getSetDefault(false, setKey: settingRefreshBackgroundBattery)
        refreshHiddenBattery     = getSetDefault(false, setKey: settingRefreshHiddenBattery)

        maxTableEntries = getSetDefault(0, setKey: settingMaxTableEntries) {$0 >= -1}
        iconSamples     = getSetDefault(64, setKey: settingIconSamples) {$0 >= -1}
        iconProcesses   = getSetDefault(7, setKey: settingIconProcesses) {$0 >= -1}

        if let psTmp = PowerSource(rawValue: getSetDefault(
                PowerSource.AC.rawValue,
                setKey: settingPowerSource)
            ) {
            powerSource = psTmp
        }
    }
}
