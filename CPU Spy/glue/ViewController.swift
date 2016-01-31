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
        sampleIntervalForeground?.doubleValue = settings.sampleIntervalForeground
        sampleIntervalBackground?.doubleValue = settings.sampleIntervalBackground
        sampleIntervalHidden?.doubleValue     = settings.sampleIntervalHidden

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
}
