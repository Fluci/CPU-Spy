//
//  AppDelegate.swift
//  CPU Spy
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SampleCollectorDelegate, IconDelegate {

    private var sampler : Sampler!;
    private var sampleCollector : SampleCollector!;
    
    private var myIcon : IconSample!;
    private var myApp : NSApplication = NSApplication.sharedApplication();
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        setDefaults();
        
        let defaults = NSUserDefaults.standardUserDefaults();
        
        // set up sampling
        sampler = FSPSSampler();
        sampleCollector = FSSampleCollector(aSampler: sampler);
        
        sampleCollector.maxSamples = 32;
        sampleCollector.delegate = self
        
        sampler.sampleInterval = defaults.doubleForKey(SAMPLE_INTERVAL_FOREGROUND)
        
        // set up dock icon
        myIcon = FSIconSample();
        myIcon.delegate = self
        myIcon.cores = NSProcessInfo.processInfo().processorCount
        myIcon.maxSamples = 64
        myIcon.username = NSUserName()
        myIcon.drawer.width = 128
        myIcon.drawer.height = 128
        myIcon.font = CTFontCreateWithName("Menlo Regular", CGFloat(10.0), nil)
        
        myApp.applicationIconImage = myIcon.drawer.icon
        
        // start sampling
        sampler.start()
        
        // add self as observer for all settings
        observeSettings()
        
    }
    
    
    // MARK: delegate-receiving
    
    func didLoadSample(sender: SampleCollector, sample: Sample) {
        // trigger passing of sample
        myIcon.addSample(sample);
        myApp.applicationIconImage = myIcon.drawer.icon;
        NSNotificationCenter.defaultCenter().postNotificationName(NEW_SAMPLE, object: (sample as! AnyObject));
    }
    
    func willRedraw(sender: Icon) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // MARK: Settings handling
    
    private func setDefaults(){
        let defaults = NSUserDefaults.standardUserDefaults();
        
        if(defaults.objectForKey(SAMPLE_INTERVAL_FOREGROUND) == nil){
            defaults.setDouble(0.5, forKey: SAMPLE_INTERVAL_FOREGROUND);
        }
    }
    
    func settingChange(aNote: NSNotification){
        switch (aNote.name) {
        case NEW_SAMPLE_INTERVAL_FOREGROUND:
            sampler.sampleInterval = aNote.object as! Double;
            NSUserDefaults.standardUserDefaults().setDouble(sampler.sampleInterval, forKey: SAMPLE_INTERVAL_FOREGROUND)
        default:
            NSLog("Unknown setting key encountered: %@", aNote.name);
        }
    }
    
    func observeSettings(){
        let observedSettings : [String] = [NEW_SAMPLE_INTERVAL_FOREGROUND];
        
        let dCenter = NSNotificationCenter.defaultCenter();
        
        for s in observedSettings {
            dCenter.addObserver(
                self,
                selector: Selector("settingChange:"),
                name: s,
                object: nil)
        }
    }
}

