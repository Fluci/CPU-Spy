//
//  ProcessTableController.swift
//  CPU Spy
//
//  Created by Felice Serena on 1.7.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa

class ProcessTableViewController : NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var processTable : NSTableView? {
        didSet {
            processTable!.setDataSource(self)
            processTable!.setDelegate(self)
            
            var col = NSTableColumn(identifier: "PID");
            col.title = "PID";
            col.width = 50;
            (col.dataCell as! NSTextFieldCell).alignment = NSTextAlignment.Right;
            processTable!.addTableColumn(col);
            
            col = NSTableColumn(identifier: "%CPU");
            col.title = "%CPU";
            col.width = 50;
            (col.dataCell as! NSTextFieldCell).alignment = NSTextAlignment.Right;
            processTable!.addTableColumn(col);
            
            col = NSTableColumn(identifier: "EXEC");
            col.title = "EXEC";
            col.width = 150;
            processTable!.addTableColumn(col);
            
            col = NSTableColumn(identifier: "COMMAND");
            col.title = "COMMAND";
            col.width = 400;
            processTable!.addTableColumn(col);
        }
    }
    
    var sample : Sample? {
        didSet {
            if(maxSamples == 0 || sample == nil){
                samples = nil;
                return;
            }
            samples = sample!.processesAll;
            // if negative: no filtering
            if(filter != nil){
                samples = samples!.filter(filter);
            }
            if(maxSamples > 0){
                samples = Array(samples!.prefix(maxSamples));
            }
            if(!sorts.isEmpty){
                for sort in sorts {
                    // TODO: not stable yet!
                    samples = samples!.sort(sort);
                }
            }
        }
    }
    var samples : [ProcessSample]?;
    var maxSamples = -1;
    var filter : (ProcessSample -> Bool)! = {$0.cpuUsagePerc != 0.0};
    var sorts : [((ProcessSample, ProcessSample) -> Bool)] = [
        //{$0.staticDat.pid < $1.staticDat.pid},
        //{$0.staticDat.exec!.lowercaseString < $1.staticDat.exec!.lowercaseString},
        {$0.cpuUsagePerc > $1.cpuUsagePerc}
    ];
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if(samples == nil){
            return 0;
        }
        return samples!.count;
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if(tableColumn == nil){
            NSLog("No column given.");
            return "<no col>";
        }
        if(samples == nil){
            NSLog("no process sample set for row %d", row);
            return "<no sample>";
        }
        
        let psmpl : ProcessSample = samples![row];
        switch tableColumn!.identifier {
        case "PID":
            return psmpl.staticDat.pid;
        case "%CPU":
            return psmpl.cpuUsagePerc*100;
        case "EXEC":
            return psmpl.staticDat.exec;
        case "COMMAND":
            return psmpl.staticDat.command;
        default:
            NSLog("Unknown col identifier encountered: \"%@\"", tableColumn!.identifier);
            return "<unknown id>";
        }
    }
    
    func newSample(smpl : Sample){
        sample = smpl;
        processTable?.reloadData()
        return;
    }
}