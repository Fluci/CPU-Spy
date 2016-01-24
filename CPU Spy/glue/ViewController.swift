//
//  ViewController.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let noteCenter = NSNotificationCenter.defaultCenter()

    var runMode: RunMode = .Foreground

    @IBOutlet var sampleIntervalForeground: NSTextField?
    @IBOutlet var sampleIntervalBackground: NSTextField?
    @IBOutlet var sampleIntervalHidden: NSTextField?

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
        let ud = userDefaults
        sampleIntervalForeground?.doubleValue = ud.doubleForKey(settingSampleIntervalForeground)
        sampleIntervalBackground?.doubleValue = ud.doubleForKey(settingSampleIntervalBackground)
        sampleIntervalHidden?.doubleValue     = ud.doubleForKey(settingSampleIntervalHidden)

        // add self as observer for settings
        noteCenter.addObserver(
            self,
            selector: Selector("newSample:"),
            name: msgNewSample,
            object: nil)

        // add self as observer for runMode
        noteCenter.addObserver(
            self,
            selector: Selector("runModeChanged:"),
            name: msgRunModeChanged,
            object: nil)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        // remove as observer, we're not showing anything anyway
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }

    // MARK: newSample handling
    func newSample(aNote: NSNotification) {
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

    @IBAction func sampleIntervalChanged(sender: NSTextField) {
        if sender.identifier == nil {
            NSLog("No sender.identifier given for interval change.")
            return
        }

        let settingKey: String
        let msgKey: String
        let newValue = sender.doubleValue

        switch sender.identifier! {
        case "sampleIntervalForeground":
            settingKey = settingSampleIntervalForeground
            msgKey = msgNewSampleIntervalForeground
        case "sampleIntervalBackground":
            settingKey = settingSampleIntervalBackground
            msgKey = msgNewSampleIntervalBackground
        case "sampleIntervalHidden":
            settingKey = settingSampleIntervalHidden
            msgKey = msgNewSampleIntervalHidden
        default:
            NSLog(
                "Unknown sender identifier encountered for interval change: %@",
                sender.identifier!)
            return
        }

        if newValue <= 0 {
            // set to one if equal-less zero
            sender.doubleValue = 1
            return
        }

        if userDefaults.doubleForKey(settingKey) == newValue {
            return
        }

        noteCenter.postNotificationName(msgKey, object: newValue)
    }

    // MARK: runMode handling

    func runModeChanged(aNote: NSNotification) {
        switch aNote.name {
        case msgRunModeChanged:

            let newModeRaw = aNote.object as? String
            if newModeRaw == nil {
                NSLog("Could not downcast object to RunMode in notification with name %@.", aNote.name)
                return
            }

            let newMode = RunMode(rawValue: newModeRaw!)
            if newMode == nil {
                NSLog("Unknown raw value for RunMode encountered: %@.", newModeRaw!)
                return
            }

            runMode = newMode!
        default:
            NSLog("runModeChanged: Unknown notification name encountered: %@", aNote.name)
        }
    }

}
