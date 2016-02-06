//
//  ViewController.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    let noteCenter = NSNotificationCenter.defaultCenter()

    @IBOutlet var sampleIntervalForeground: NSTextField?
    @IBOutlet var sampleIntervalBackground: NSTextField?
    @IBOutlet var sampleIntervalHidden:     NSTextField?

    @IBOutlet var refreshForeground: NSButton?
    @IBOutlet var refreshBackground: NSButton?
    @IBOutlet var refreshHidden:     NSButton?

    @IBOutlet var maxTableEntries: NSTextField?
    @IBOutlet var iconSamples:     NSTextField?
    @IBOutlet var iconProcesses:   NSTextField?

    @IBOutlet var powerSource: NSPopUpButton?

    var processTableViewController: ProcessTableViewController! = ProcessTableViewController()

    @IBOutlet var processTableView: NSTableView? {
        didSet {
            processTableViewController.processTable = processTableView
        }
    }


    // MARK: Appearance control
    override func viewWillAppear() {
        super.viewWillAppear()

        // read settings from UserDefaults

        powerSource?.selectItemWithTag(settings.powerSource == .AC ? 1 : 2)

        updatePowerSourceDependent()

        maxTableEntries?.integerValue = settings.maxTableEntries
        iconSamples?.integerValue     = settings.iconSamples
        iconProcesses?.integerValue   = settings.iconProcesses

        // add self as observer for settings
        noteCenter.addObserver(
            self,
            selector: Selector("newSample:"),
            name: msgNewSample,
            object: nil)
    }

    private func updatePowerSourceDependent(){
        switch settings.powerSource {
        case .AC:
            sampleIntervalForeground?.doubleValue = settings.sampleIntervalForegroundAC
            sampleIntervalBackground?.doubleValue = settings.sampleIntervalBackgroundAC
            sampleIntervalHidden?.doubleValue     = settings.sampleIntervalHiddenAC

            refreshForeground?.state = settings.refreshForegroundAC ? NSOnState : NSOffState
            refreshBackground?.state = settings.refreshBackgroundAC ? NSOnState : NSOffState
            refreshHidden?.state     = settings.refreshHiddenAC     ? NSOnState : NSOffState
        default:
            sampleIntervalForeground?.doubleValue = settings.sampleIntervalForegroundBattery
            sampleIntervalBackground?.doubleValue = settings.sampleIntervalBackgroundBattery
            sampleIntervalHidden?.doubleValue     = settings.sampleIntervalHiddenBattery

            refreshForeground?.state = settings.refreshForegroundBattery ? NSOnState : NSOffState
            refreshBackground?.state = settings.refreshBackgroundBattery ? NSOnState : NSOffState
            refreshHidden?.state     = settings.refreshHiddenBattery     ? NSOnState : NSOffState
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        // remove as observer, we're not showing anything anyway
        noteCenter.removeObserver(self)

    }

    func shouldAcceptNewSample() -> Bool {
        switch (appState.runMode, appState.powerSource) {
        case (.Foreground, .AC):
            return settings.refreshForegroundAC
        case (.Background, .AC):
            return settings.refreshBackgroundAC
        case (.Hidden, .AC):
            return settings.refreshHiddenAC
        case (.Foreground, .Battery):
            return settings.refreshForegroundBattery
        case (.Background, .Battery):
            return settings.refreshBackgroundBattery
        case (.Hidden, .Battery):
            return settings.refreshHiddenBattery
        }
    }

    // MARK: newSample handling
    func newSample(aNote: NSNotification) {
        if     !shouldAcceptNewSample() {
            return
        }
        switch aNote.name {
        case msgNewSample:
            if let sample = aNote.object as? Sample {
                processTableViewController.newSample(sample)
            } else {
                NSLog(
                    "Could not downcast object to Sample in notification with name %@.",
                    aNote.name)
            }
        default:
            NSLog("newSample: Unknown notification name encountered: %@", aNote.name)
        }
    }

    // MARK: settings handling

    @IBAction func buttonChanged(sender: NSButton) {
        if sender.identifier == nil {
            NSLog("No sender.identifier given for button change.")
            return
        }

        if sender.identifier != "powerSource" {
            NSLog("Unconfigured identifier encountered: %@", sender.identifier!)
            return
        }

        var psTag = powerSource?.selectedItem?.tag

        if psTag == nil {
            NSLog("No tag detected.")
            return
        }

        if psTag != 1 && psTag != 2 {
            NSLog("Unexpected tag value of powerSource encountered: %@", psTag!)
            psTag = 1
        }

        settings.powerSource = 1 == psTag ? .AC : .Battery

        updatePowerSourceDependent()
    }
    @IBAction func refreshChanged(sender: NSButton) {
        if sender.identifier == nil {
            NSLog("No sender.identifier given for refresh change.")
            return
        }

        var newValue = sender.state

        if newValue == NSMixedState {
            // set to one if equal-less zero
            sender.state = NSOnState
            newValue = NSOnState
        }

        switch (settings.powerSource, sender.identifier!) {
        case (.AC, "refreshForeground"):
            settings.refreshForegroundAC = newValue == NSOnState
        case (.AC, "refreshBackground"):
            settings.refreshBackgroundAC = newValue == NSOnState
        case (.AC, "refreshHidden"):
            settings.refreshHiddenAC = newValue == NSOnState
        case (.Battery, "refreshForeground"):
            settings.refreshForegroundBattery = newValue == NSOnState
        case (.Battery, "refreshBackground"):
            settings.refreshBackgroundBattery = newValue == NSOnState
        case (.Battery, "refreshHidden"):
            settings.refreshHiddenBattery = newValue == NSOnState
        default:
            NSLog(
                "Unknown sender identifier encountered for refresh change: %@",
                sender.identifier!)
            return
        }

    }

    @IBAction func sampleIntervalChanged(sender: NSTextField) {
        if sender.identifier == nil {
            NSLog("No sender.identifier given for interval change.")
            return
        }

        var newValue = sender.doubleValue
        if newValue <= 0 {
            // set to one if equal-less zero
            sender.doubleValue = 1
            newValue = 1
        }

        switch (settings.powerSource, sender.identifier!) {
        case (.AC, "sampleIntervalForeground"):
            settings.sampleIntervalForegroundAC = newValue
        case (.AC, "sampleIntervalBackground"):
            settings.sampleIntervalBackgroundAC = newValue
        case (.AC, "sampleIntervalHidden"):
            settings.sampleIntervalHiddenAC = newValue
        case (.Battery, "sampleIntervalForeground"):
            settings.sampleIntervalForegroundBattery = newValue
        case (.Battery, "sampleIntervalBackground"):
            settings.sampleIntervalBackgroundBattery = newValue
        case (.Battery, "sampleIntervalHidden"):
            settings.sampleIntervalHiddenBattery = newValue
        default:
            NSLog(
                "Unknown sender identifier encountered for interval change: %@",
                sender.identifier!)
            return
        }
    }

    @IBAction func textEntriesChanged(sender: NSTextField) {
        if sender.identifier == nil {
            NSLog("No sender.identifier given for entries change.")
            return
        }

        var newValue = sender.integerValue
        if newValue < -1 {
            newValue = 5
        }
        // Always update to remove decimal points
        sender.integerValue = newValue

        switch sender.identifier! {
        case "tableEntries":
            settings.maxTableEntries = newValue
        case "iconSamples":
            settings.iconSamples = newValue
        case "iconProcesses":
            settings.iconProcesses = newValue
        default:
            NSLog("Unknown sender identifier encountered for entries change: %@",
            sender.identifier!)
            return
        }
    }
}
