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
private let powerSourceCallback: IOPowerSourceCallbackType = { (ptr: UnsafeMutablePointer<Void>) in
    let appDel = Unmanaged<AppDelegate>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
    appDel.batteryChanged()
}



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SampleCollectorDelegate, IconDelegate {

    private var sampler: Sampler!
    private var sampleCollector: SampleCollector!

    private var myIcon: IconSample?
    private var myApp: NSApplication = NSApplication.sharedApplication()

    private let noteCenter = NSNotificationCenter.defaultCenter()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        if let runLoopSource = IOPSCreateLimitedPowerNotification(
            powerSourceCallback,
            UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque()))?.takeRetainedValue() {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
        } else {
            NSLog("Observing of powerSource failed.")
        }

        // set up sampling
        sampler = FSPSSampler()
        sampleCollector = FSSampleCollector(aSampler: sampler)

        sampleCollector.maxSamples = 1 // we don't need more for the moment
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
        batteryChanged()

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
        switch aNote.name {
        case settings.msgNewSampleIntervalForegroundAC:
            updateSampleInterval()
        case settings.msgNewSampleIntervalBackgroundAC:
            updateSampleInterval()
        case settings.msgNewSampleIntervalHiddenAC:
            updateSampleInterval()
        case settings.msgNewSampleIntervalForegroundBattery:
            updateSampleInterval()
        case settings.msgNewSampleIntervalBackgroundBattery:
            updateSampleInterval()
        case settings.msgNewSampleIntervalHiddenBattery:
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

    func batteryChanged() {
        let source = IOPSGetProvidingPowerSourceType(nil)!.takeRetainedValue() as String
        appState.powerSource = kIOPMACPowerKey == source ? .AC : .Battery
        updateSampleInterval()
        debugPrint("Changed to powerSource: \(appState.powerSource)")
    }

    func observeSettings() {
        let observedSettings: [String] = [
            settings.msgNewSampleIntervalForegroundAC,
            settings.msgNewSampleIntervalBackgroundAC,
            settings.msgNewSampleIntervalHiddenAC,
            settings.msgNewSampleIntervalForegroundBattery,
            settings.msgNewSampleIntervalBackgroundBattery,
            settings.msgNewSampleIntervalHiddenBattery,
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
        switch (appState.runMode, appState.powerSource) {
        case (.Foreground, .AC):
            sampler.sampleInterval = settings.sampleIntervalForegroundAC
        case (.Background, .AC):
            sampler.sampleInterval = settings.sampleIntervalBackgroundAC
        case (.Hidden, .AC):
            sampler.sampleInterval = settings.sampleIntervalHiddenAC
        case (.Foreground, .Battery):
            sampler.sampleInterval = settings.sampleIntervalForegroundBattery
        case (.Background, .Battery):
            sampler.sampleInterval = settings.sampleIntervalBackgroundBattery
        case (.Hidden, .Battery):
            sampler.sampleInterval = settings.sampleIntervalHiddenBattery

        }
    }

    var overviewController: NSWindowController?

    @IBAction func openOverview(sender: AnyObject) {
        let app = NSApplication.sharedApplication()
        app.activateIgnoringOtherApps(true)
        overviewController?.window?.makeKeyAndOrderFront(self)
        debugPrint("opening overview")
    }
}
