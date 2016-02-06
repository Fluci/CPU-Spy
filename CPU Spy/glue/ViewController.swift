//
//  ViewController.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

/**
 Handles the interaction with the MainWindow, except the processTable which is mainly
 controlled by processTableViewController.
*/
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
        sampleIntervalForeground?.doubleValue = settings.sampleIntervalForeground
        sampleIntervalBackground?.doubleValue = settings.sampleIntervalBackground
        sampleIntervalHidden?.doubleValue     = settings.sampleIntervalHidden

        refreshForeground?.state = settings.refreshForeground ? NSOnState : NSOffState
        refreshBackground?.state = settings.refreshBackground ? NSOnState : NSOffState
        refreshHidden?.state     = settings.refreshHidden     ? NSOnState : NSOffState

        maxTableEntries?.integerValue = settings.maxTableEntries
        iconSamples?.integerValue     = settings.iconSamples
        iconProcesses?.integerValue   = settings.iconProcesses

        processTableViewController.settings = settings

        // add self as observer for settings
        noteCenter.addObserver(
            self,
            selector: Selector("newSample:"),
            name: msgNewSample,
            object: nil)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        // remove as observer, we're not showing anything anyway
        noteCenter.removeObserver(self)

    }

    // MARK: newSample handling
    func newSample(aNote: NSNotification) {
        if     (appState.runMode == .Foreground && !settings.refreshForeground)
            || (appState.runMode == .Background && !settings.refreshBackground)
            || (appState.runMode == .Hidden     && !settings.refreshHidden) {
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

    // MARK: sampleIntervalX handling

    @IBAction func refreshChanged(sender: NSButton) {
        if sender.identifier == nil {
            NSLog("No sender.identifier given for interval change.")
            return
        }

        var newValue = sender.state

        if newValue == NSMixedState {
            // set to one if equal-less zero
            sender.state = NSOnState
            newValue = NSOnState
        }

        switch sender.identifier! {
        case "refreshForeground":
            settings.refreshForeground = newValue == NSOnState
        case "refreshBackground":
            settings.refreshBackground = newValue == NSOnState
        case "refreshHidden":
            settings.refreshHidden = newValue == NSOnState
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

        switch sender.identifier! {
        case "sampleIntervalForeground":
            settings.sampleIntervalForeground = newValue
        case "sampleIntervalBackground":
            settings.sampleIntervalBackground = newValue
        case "sampleIntervalHidden":
            settings.sampleIntervalHidden = newValue
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
