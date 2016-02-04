//
//  AppDelegate.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

/**
 Main entry point of application.
 
 The AppDelegate is the core of the application.
 It sets everything up and handles application related events.
 AppDelegate propagates value changes from the view to the model and other views
 by listening to the NSNotificationCenter. didLoadSample triggers the propagation
 from the model (sampler) towards the views.

*/

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SampleCollectorDelegate, IconDelegate {

    private var sampler: Sampler!
    private var sampleCollector: SampleCollector!

    private var myIcon: IconSample?
    private var myApp: NSApplication = NSApplication.sharedApplication()

    private let noteCenter = NSNotificationCenter.defaultCenter()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        // set up sampling
        sampler = FSPSSampler()
        sampleCollector = FSSampleCollector(aSampler: sampler)

        sampleCollector.maxSamples = 32
        sampleCollector.delegate = self

        // set up dock icon
        let icon = FSIconSample()
        icon.delegate = self
        icon.cores = NSProcessInfo.processInfo().processorCount
        icon.maxSamples = settings.iconSamples
        icon.entries = settings.iconProcesses
        icon.username = NSUserName()
        icon.drawer.width = 128
        icon.drawer.height = 128
        icon.font = CTFontCreateWithName("Menlo Regular", CGFloat(10.0), nil)
        myIcon = icon

        updateSampleInterval()

        myApp.applicationIconImage = myIcon?.drawer.icon

        // start sampling
        sampler.start()

        // add self as observer for all settings
        observeSettings()
    }


    // MARK: delegate-receiving

    func didLoadSample(sender: SampleCollector, sample: Sample) {
        // trigger passing of sample
        if let icon = myIcon {
            icon.addSample(sample)
            myApp.applicationIconImage = icon.drawer.icon
        }
        let obj = sample as? AnyObject
        if obj == nil {
            NSLog("Couldn't cast Sample to AnyObject.")
        }
        noteCenter.postNotificationName(msgNewSample, object: obj)
    }

    func willRedraw(sender: Icon) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        sampler.stop()
    }

    // MARK: Settings handling

    func settingChange(aNote: NSNotification) {
        let val = aNote.object as? Double
        if val == nil {
            NSLog("Couldn't unwrap new setting from message, name: %@", aNote.name)
            return
        }
        switch aNote.name {
        case settings.msgNewSampleIntervalForeground:
            updateSampleInterval()
        case settings.msgNewSampleIntervalBackground:
            updateSampleInterval()
        case settings.msgNewSampleIntervalHidden:
            updateSampleInterval()
        case settings.msgNewIconSamples:
            myIcon?.maxSamples = settings.iconSamples
        case settings.msgNewIconProcesses:
            myIcon?.entries = settings.iconProcesses
        default:
            NSLog("Unconfigured notification name encountered: %@",
                aNote.name
            )
        }
    }

    func observeSettings() {
        let observedSettings: [String] = [
            settings.msgNewSampleIntervalForeground,
            settings.msgNewSampleIntervalBackground,
            settings.msgNewSampleIntervalHidden,
            settings.msgNewIconSamples,
            settings.msgNewIconProcesses
        ]

        for s in observedSettings {
            settings.noteCenter.addObserver(
                self,
                selector: Selector("settingChange:"),
                name: s,
                object: nil)
        }
    }

    // MARK: runMode

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
        if newMode == appState.runMode {
            // nothing changed
            return
        }
        appState.runMode = newMode
        updateSampleInterval()
    }

    // MARK: Sampler updating

    func updateSampleInterval() {
        switch appState.runMode {
        case .Foreground:
            sampler.sampleInterval = settings.sampleIntervalForeground
        case .Background:
            sampler.sampleInterval = settings.sampleIntervalBackground
        case .Hidden:
            sampler.sampleInterval = settings.sampleIntervalHidden

        }
    }
}
