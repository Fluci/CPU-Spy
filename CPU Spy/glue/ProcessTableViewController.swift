//
//  ProcessTableController.swift
//  CPU Spy
//
//  Created by Felice Serena on 1.7.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa


class ProcessTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var processTable: NSTableView? {
        didSet {
            processTable!.setDataSource(self)
            processTable!.setDelegate(self)

            // hard coded columns for the moment
            var col = NSTableColumn(identifier: "PID")
            col.title = "PID"
            col.width = 50
            (col.dataCell as? NSTextFieldCell)!.alignment = NSTextAlignment.Right
            processTable!.addTableColumn(col)

            col = NSTableColumn(identifier: "%CPU")
            col.title = "%CPU"
            col.width = 50
            (col.dataCell as? NSTextFieldCell)!.alignment = NSTextAlignment.Right
            processTable!.addTableColumn(col)

            col = NSTableColumn(identifier: "EXEC")
            col.title = "EXEC"
            col.width = 150
            processTable!.addTableColumn(col)

            col = NSTableColumn(identifier: "COMMAND")
            col.title = "COMMAND"
            col.width = 400
            processTable!.addTableColumn(col)
        }
    }

    var sample: Sample? {
        didSet {
            let mSamples = maxSamples

            if mSamples == 0 || sample == nil {
                samples = nil
                return
            }
            samples = sample!.processesAll
            // if negative: no filtering
            if filter != nil {
                samples = samples!.filter(filter)
            }
            if mSamples > 0 {
                samples = Array(samples!.prefix(mSamples))
            }
            if !sorts.isEmpty {
                for sort in sorts {
                    // TODO: not stable yet!
                    samples = samples!.sort(sort)
                }
            }
        }
    }
    var settings: Settings?

    var samples: [ProcessSample]?
    var maxSamples : Int {
        get {
            return settings == nil ? -1 : settings!.maxTableEntries
        }
    }
    var filter: (ProcessSample -> Bool)! = {$0.cpuUsagePerc != 0.0}

    /// Evaluated from top to bottom. The last comparator decides the total order etc.
    /// Note: not stable yet
    var sorts: [((ProcessSample, ProcessSample) -> Bool)] = [ {$0.cpuUsagePerc > $1.cpuUsagePerc}
    ]

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if samples == nil {
            return 0
        }
        return samples!.count
    }

    func tableView(
        tableView: NSTableView,
        objectValueForTableColumn tableColumn: NSTableColumn?,
        row: Int) -> AnyObject? {
        if tableColumn == nil {
            NSLog("No column given.")
            return "<no col>"
        }
        if samples == nil {
            NSLog("no process sample set for row %d", row)
            return "<no sample>"
        }

        let psmpl: ProcessSample = samples![row]
        switch tableColumn!.identifier {
        case "PID":
            return psmpl.staticDat.pid
        case "%CPU":
            return psmpl.cpuUsagePerc*100
        case "EXEC":
            return psmpl.staticDat.exec
        case "COMMAND":
            return psmpl.staticDat.command
        default:
            NSLog("Unknown col identifier encountered: \"%@\"", tableColumn!.identifier)
            return "<unknown id>"
        }
    }

    func newSample(smpl: Sample) {
        sample = smpl
        processTable?.reloadData()
        return
    }
}
