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
                samples = samples!.sort({
                    (a: ProcessSample, b: ProcessSample) -> Bool in
                    for sort in self.sorts {
                        switch sort(a, b){
                        case 1:
                            return true
                        case -1:
                            return false
                        default:
                            ()
                        }
                    }
                    return false
                })
            }
        }
    }

    var samples: [ProcessSample]?
    var maxSamples : Int {
        get {
            return settings.maxTableEntries
        }
    }

    /// example: {$0.cpuUsagePerc != 0.0}
    var filter: (ProcessSample -> Bool)! = {_ in true}

    /// compared from first to last, the first rule returning != 0 decides
    /// -1 means end of list, 1 means start of list
    var sorts: [((ProcessSample, ProcessSample) -> Int)] = [
        {$0.cpuUsagePerc > $1.cpuUsagePerc ? 1 : ($0.cpuUsagePerc == $1.cpuUsagePerc ? 0 : -1)},
        {$0.staticDat.pid > $1.staticDat.pid ? -1 : ($0.staticDat.pid == $1.staticDat.pid ? 0 : 1)}
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
            return psmpl.cpuUsagePerc * 100
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
