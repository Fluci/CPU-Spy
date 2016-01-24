//
//  AppDelegate.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SampleCollectorDelegate, FSIconDelegate {

    private var sampler : Sampler!;
    private var sampleCollector : SampleCollector!;
    
    private var myIcon = FSIconSample()
    private var myApp : NSApplication = NSApplication.sharedApplication();
    
    private var thisUser : String = NSUserName();
    
    
    private func setDefaults(){
        let defaults = NSUserDefaults.standardUserDefaults();
        
        if(defaults.objectForKey(SAMPLE_INTERVAL_FOREGROUND) == nil){
            defaults.setDouble(0.3, forKey: SAMPLE_INTERVAL_FOREGROUND)
        }
    }
    
    func settingChange(aNote: NSNotification){
        if(aNote.name == NEW_SAMPLE_INTERVAL_FOREGROUND){
            sampler.sampleInterval = aNote.object as! Double;
            NSUserDefaults.standardUserDefaults().setDouble(sampler.sampleInterval, forKey: SAMPLE_INTERVAL_FOREGROUND)
            return;
        }
        NSLog("Unknown setting key encountered: %@", aNote.name);
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        let defaults = NSUserDefaults.standardUserDefaults();
        
        setDefaults();
        
        sampler = FSPSSampler();
        sampleCollector = FSSampleCollector(aSampler: sampler);
        
        sampleCollector.maxSamples = 32;
        sampleCollector.delegate = self
        
        sampler.sampleInterval = defaults.doubleForKey(SAMPLE_INTERVAL_FOREGROUND)
        
        sampler.start()
        
        myIcon.delegate = self
        myIcon.cores = NSProcessInfo.processInfo().processorCount
        let mult = 2.0
        myIcon.maxSamples = 64
        myIcon.width = 64*mult
        myIcon.height = 64*mult
        myIcon.font = CTFontCreateWithName("Menlo Regular", CGFloat(5.0 * mult), nil)
        
        myApp.applicationIconImage = myIcon.icon
        
        let dCenter = NSNotificationCenter.defaultCenter();
        dCenter.addObserver(
            self,
            selector: Selector("settingChange:"),
            name: NEW_SAMPLE_INTERVAL_FOREGROUND,
            object: nil)
    }
    
    // MARK: delegate-receiving
    func didLoadSample(sender: SampleCollector, sample: Sample) {
        // trigger passing of sample
        myIcon.addSample(sample)
        myApp.applicationIconImage = myIcon.icon
        NSNotificationCenter.defaultCenter().postNotificationName(NEW_SAMPLE, object: (sample as! AnyObject));
    }
    internal func willRedraw(sender: FSIcon) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

