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
        if(aNote.name == NEW_SAMPLE){
            let sample = (aNote.object as! Sample);
            processTableViewController.newSample(sample);
            return;
        }
        NSLog("Unknown notification name encountered: %@", aNote.name);
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        let defaults = NSUserDefaults.standardUserDefaults();
        
        sampleIntervalForeground?.doubleValue = defaults.doubleForKey(SAMPLE_INTERVAL_FOREGROUND);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("newSample:"), name: NEW_SAMPLE, object: nil)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear();

        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }

}

