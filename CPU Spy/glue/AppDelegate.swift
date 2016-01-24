//
//  AppDelegate.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SampleCollectorDelegate, IconDelegate {

    private var sampler: Sampler!
    private var sampleCollector: SampleCollector!

    private var myIcon: IconSample!
    private var myApp: NSApplication = NSApplication.sharedApplication()

    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let noteCenter = NSNotificationCenter.defaultCenter()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        setDefaults()

        // set up sampling
        sampler = FSPSSampler()
        sampleCollector = FSSampleCollector(aSampler: sampler)

        sampleCollector.maxSamples = 32
        sampleCollector.delegate = self

        // set up dock icon
        myIcon = FSIconSample()
        myIcon.delegate = self
        myIcon.cores = NSProcessInfo.processInfo().processorCount
        myIcon.maxSamples = 64
        myIcon.username = NSUserName()
        myIcon.drawer.width = 128
        myIcon.drawer.height = 128
        myIcon.font = CTFontCreateWithName("Menlo Regular", CGFloat(10.0), nil)
        updateSampleInterval()

        myApp.applicationIconImage = myIcon.drawer.icon

        // start sampling
        sampler.start()

        // add self as observer for all settings
        observeSettings()
    }


    // MARK: delegate-receiving

    func didLoadSample(sender: SampleCollector, sample: Sample) {
        // trigger passing of sample
        myIcon.addSample(sample)
        myApp.applicationIconImage = myIcon.drawer.icon
        let obj = sample as? AnyObject;
        if obj == nil {
            NSLog("Couldn't cast Sample to AnyObject.");
        }
        noteCenter.postNotificationName(msgNewSample, object: obj)
    }

    func willRedraw(sender: Icon) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    // MARK: Settings handling

    private func setDefaults() {
        if userDefaults.objectForKey(settingSampleIntervalForeground) == nil {
            userDefaults.setDouble(1, forKey: settingSampleIntervalForeground)
        }
        if userDefaults.objectForKey(settingSampleIntervalBackground) == nil {
            userDefaults.setDouble(5, forKey: settingSampleIntervalBackground)
        }
        if userDefaults.objectForKey(settingSampleIntervalHidden) == nil {
            userDefaults.setDouble(10, forKey: settingSampleIntervalHidden)
        }
    }

    func settingChange(aNote: NSNotification) {
        let val = aNote.object as? Double
        if val == nil {
            NSLog("Couldn't unwrap new sampleInterval from message, name: %@", aNote.name)
            return
        }

        switch aNote.name {
        case msgNewSampleIntervalForeground:
            userDefaults.setDouble(val!, forKey: settingSampleIntervalForeground)
        case msgNewSampleIntervalBackground:
            userDefaults.setDouble(val!, forKey: settingSampleIntervalBackground)
        case msgNewSampleIntervalHidden:
            userDefaults.setDouble(val!, forKey: settingSampleIntervalHidden)
        default:
            NSLog("Unknown setting key encountered: %@", aNote.name)
            return
        }
        updateSampleInterval()
    }

    func observeSettings() {
        let observedSettings: [String] = [
            msgNewSampleIntervalForeground,
            msgNewSampleIntervalBackground,
            msgNewSampleIntervalHidden
        ]

        for s in observedSettings {
            noteCenter.addObserver(
                self,
                selector: Selector("settingChange:"),
                name: s,
                object: nil)
        }
    }

    // MARK: runMode

    private var runMode: RunMode = .Foreground

    func applicationWillBecomeActive(notification: NSNotification) {
        // user is in the application, focus on app
        updateRunMode(.Foreground)
    }

    func applicationDidResignActive(notification: NSNotification) {
        // called if app is no longer in focus
        // we have to check if it has been hidden or just moved to background
        if myApp.hidden {
            updateRunMode(.Hidden)
        } else {
            updateRunMode(.Background)
        }
    }

    func applicationDidHide(notification: NSNotification) {
        updateRunMode(.Hidden)
    }

    func updateRunMode(newMode: RunMode) {
        if newMode == runMode {
            // nothing changed
            return
        }
        runMode = newMode
        updateSampleInterval()
        noteCenter.postNotificationName(msgRunModeChanged, object: runMode.rawValue)
    }

    // MARK: Sampler updating

    func updateSampleInterval() {
        switch runMode {
        case .Foreground:
            sampler.sampleInterval = userDefaults.doubleForKey(settingSampleIntervalForeground)
        case .Background:
            sampler.sampleInterval = userDefaults.doubleForKey(settingSampleIntervalBackground)
        case .Hidden:
            sampler.sampleInterval = userDefaults.doubleForKey(settingSampleIntervalHidden)

        }
    }
}
