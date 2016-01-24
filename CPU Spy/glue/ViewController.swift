//
//  ViewController.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var sampleIntervalForeground: NSTextField?

    @IBAction func sampleIntervalForegroundChanged(sender: NSTextField) {
        if NSUserDefaults.standardUserDefaults()
            .doubleForKey(settingSampleIntervalForeground) == sender.doubleValue {
            return
        }
        NSNotificationCenter.defaultCenter()
            .postNotificationName(msgNewSampleIntervalForeground, object: sender.doubleValue)
    }

    var processTableViewController: ProcessTableViewController! = ProcessTableViewController()
    @IBOutlet var processTableView: NSTableView? {
        didSet {
            processTableViewController.processTable = processTableView
        }
    }

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
            NSLog("Unknown notification name encountered: %@", aNote.name)
        }
    }

    // MARK: Appearance control
    override func viewWillAppear() {
        super.viewWillAppear()

        let defaults = NSUserDefaults.standardUserDefaults()

        // read settings from UserDefaults
        sampleIntervalForeground?.doubleValue = defaults
            .doubleForKey(settingSampleIntervalForeground)

        // add self as observer for settings
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: Selector("newSample:"), name: msgNewSample, object: nil)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        // remove as observer, we're not showing anything anyway
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }

}
