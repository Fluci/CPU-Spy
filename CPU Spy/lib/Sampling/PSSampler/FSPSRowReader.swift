//
//  FSPSRowReader.swift
//  CPU Spy
//
//  Created by Felice Serena on 18.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

public class FSPSRowReader {

    private let commandSplitter: CommandSplitter

    init(aSplitter: CommandSplitter = FSPSCommandSplitter()) {
        commandSplitter = aSplitter
    }

    public var titleMap: [String : Int]!

    // MARK: read row to processSample

    private var activeLine = [FSString]()

    let dateFormatter = NSDateFormatter()

    /// main entry: defines mapping between ps-cols and corresponding processorSample attributes
    public func readRow(let line: [FSString]) -> ProcessSample {
        let pSmpl = FSProcessSample()
        activeLine = line

        pSmpl.staticDat = staticDatFromActiveLine()

        if let percStr = getFromLine("%CPU")?
            .stringByReplacingOccurrencesOfString(",", withString: ".") {
            if let perc = Double(percStr) {
                pSmpl.cpuUsagePerc = perc * 0.01
            } else {
                NSLog("%@", "Could not read cpu value: \(percStr)")
            }
        }

        pSmpl.xstat = getFromLine("XSTAT", transform: {Int($0)})
        //pSmpl.stat = getFromLine("STAT", transform: {FSProcessSample});
        pSmpl.signalsPending = getFromLine("PENDING", transform: {$0})
        pSmpl.signalsBlocked = getFromLine("BLOCKED", transform: {$0})

        assert(pSmpl.cpuUsagePerc != nil)
        assert(pSmpl.staticDat.exec != nil)

        return pSmpl
    }
    var staticDats = [Int : FSProcessSampleStatic]()
    private func staticDatFromActiveLine() -> FSProcessSampleStatic {

        let pid = getFromLine("PID", transform: {Int($0)!})
        let command = getFromLine("COMMAND", transform: {$0})

        // search cache
        if let candidate = staticDats[pid] {
            if candidate.command == command {
                return candidate
            }
        }
        let staticDat = FSProcessSampleStatic()
        staticDat.pid = pid
        staticDat.command = command

        // parse command
        let (p, e, a) = splitCommand(activeLine[titleMap["COMMAND"]!])
        staticDat.executionPath = p
        staticDat.exec = e
        staticDat.executionArguments = a

        // command parsing end

        staticDat.user = getFromLine("USER", transform: {$0})

        staticDat.ppid = getFromLine("PPID", transform: {Int($0)})
        staticDat.pgid = getFromLine("PGID", transform: {Int($0)})
        staticDat.gid = getFromLine("GID", transform: {Int($0)})
        staticDat.uid = getFromLine("UID", transform: {Int($0)})
        staticDat.rgid = getFromLine("RGID", transform: {Int($0)})
        staticDat.ruid = getFromLine("RUID", transform: {Int($0)})
        staticDat.ruser = getFromLine("RUSER", transform: {$0})
        staticDat.startDate = getFromLine(
            "STARTED",
            transform: {self.dateFormatter.dateFromString($0)})

        // might overwrite an old one
        staticDats[staticDat.pid] = staticDat

        return staticDat
    }
    private func splitCommand(command: FSString) -> (path: String!, exec: String, args: [String]) {
        let (p, e, arguments) = commandSplitter.split(command)
        var args = [String]()

        for arg in arguments {
            args.append(arg.string())
        }

        return (path: p?.string(), e.string(), args: args)
    }

    // MARK: read row helper
    private func getFromLine(titleKey: String) -> String? {
        return getFromLine(titleKey, transform: {$0})
    }
    private func getFromLine<T>(titleKey: String, transform: (String) -> T) -> T! {
        let index = titleMap[titleKey]
        return getVal(activeLine, index: index, transform: transform)
    }

    private func getVal<T>(line: [FSString], index: Int!, transform: (String) -> T) -> T! {
        if index == nil {
            return nil
        }
        let str = line[index].string()
        return transform(str)
    }
}
