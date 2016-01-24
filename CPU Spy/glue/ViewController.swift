//
//  ViewController.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var sampleIntervalForeground : NSTextField?;
    
    @IBAction func sampleIntervalForegroundChanged(sender: NSTextField){
        if(NSUserDefaults.standardUserDefaults().doubleForKey(SAMPLE_INTERVAL_FOREGROUND) == sender.doubleValue){
            return;
        }
        NSNotificationCenter.defaultCenter().postNotificationName(NEW_SAMPLE_INTERVAL_FOREGROUND, object: sender.doubleValue)
    }
    
    var processTableViewController : ProcessTableViewController! = ProcessTableViewController()
    @IBOutlet var processTableView : NSTableView? {
        didSet{
            processTableViewController.processTable = processTableView
        }
    }
    
    func newSample(aNote : NSNotification){
        switch(aNote.name) {
        case NEW_SAMPLE:
            let sample = (aNote.object as! Sample);
            processTableViewController.newSample(sample);
        default:
            NSLog("Unknown notification name encountered: %@", aNote.name);
        }
    }
    
    // MARK: Appearance control
    override func viewWillAppear() {
        super.viewWillAppear();
        
        let defaults = NSUserDefaults.standardUserDefaults();
        
        // read settings from UserDefaults
        sampleIntervalForeground?.doubleValue = defaults.doubleForKey(SAMPLE_INTERVAL_FOREGROUND);
        
        // add self as observer for settings
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("newSample:"), name: NEW_SAMPLE, object: nil)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear();

        // remove as observer, we're not showing anything anyway
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }

}

