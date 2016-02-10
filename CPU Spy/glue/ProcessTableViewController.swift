//
//  ProcessTableController.swift
//  CPU Spy
//
//  Created by Felice Serena on 1.7.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa

/**
 This class is responsible to handle the interaction with the ProcessTable in the main window.
 */
class ProcessTableViewController: NSViewController, NSTableViewDelegate, FSMergedTableViewDataSource {
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

    var refresh = true

    var clippedSamples = 0

    var sample: Sample? {
        didSet {
            let mSamples = maxSamples

            if sample == nil {
                samples = Array()
                return
            }
            samples = sample!.processesAll
            // if negative: no filtering
            if filter != nil {
                samples = samples!.filter(filter)
            }
            if mSamples >= 0 {
                clippedSamples = samples!.count
                samples = Array(samples!.prefix(mSamples))
                clippedSamples -= samples!.count
            }
            if !sorts.isEmpty {
                samples = samples!.sort({
                    (a: ProcessSample, b: ProcessSample) -> Bool in
                    for sort in self.sorts {
                        switch sort(a, b) {
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
    var maxSamples: Int {
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


    // MARK: delegate methods

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if !refresh {
            return 1
        }
        if samples == nil {
            return 1
        }
        if clippedSamples > 0 {
            return samples!.count + 1
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

            if !refresh {
                return makeOneLine("View refresh turned off.")
            }
            if samples == nil {
                return makeOneLine("No data available.")
            }
            if samples!.count == row {
                return makeOneLine("\(clippedSamples) process samples clipped.")
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

    func tableView(
        tableView: FSMergedTableView,
        spanForTableColumn tableColumn: NSTableColumn,
        row: Int
        ) -> Int {
            // onelines
            if !refresh || samples == nil || samples!.count == row {
                return processTable!.tableColumns.first!.identifier == tableColumn.identifier ? processTable!.tableColumns.count : 0
            }

            return 1
    }

    func newSample(smpl: Sample) {
        sample = smpl
        processTable?.reloadData()
        return
    }

    // MARK: Helper

    private func makeOneLine(value: String) -> AnyObject? {
        let cell = makeOneLineCell()
        cell.stringValue = value
        return cell
    }

    private func makeOneLineCell() -> NSCell {
        let cell = NSCell()
        cell.alignment = .Center
        cell.bordered = true
        cell.backgroundStyle = .Dark
        return cell
    }
}
