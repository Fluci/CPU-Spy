//
//  FSPSRowReader.swift
//  CPU Spy
//
//  Created by Felice Serena on 18.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

/*
    Reads a single row and produces a ProcessSample.
    titleMap has to be set by the client to map the collumns correctly 
    to process sample attributes.
*/

public class FSPSRowReader {

    private let commandSplitter: CommandSplitter

    init(aSplitter: CommandSplitter = FSPSCommandSplitter()) {
        commandSplitter = aSplitter
    }

    public var titleMap: [String : Int]!

    // MARK: read row to processSample

    let dateFormatter = NSDateFormatter()

    /// main entry: defines mapping between ps-cols and corresponding processorSample attributes
    public func readRow(line: [FSString]) -> ProcessSample {
        let pSmpl = FSProcessSample()

        pSmpl.staticDat = staticDatFromLine(line)

        let percFStr: FSString = line[titleMap["%CPU"]!]
        let percStr: String

        if percFStr.findNext(ASCII.Comma.rawValue as CChar) != percFStr.length {
            percStr = percFStr.string().stringByReplacingOccurrencesOfString(",", withString: ".")
        } else {
            percStr = percFStr.string()
        }

        if let perc = Double(percStr) {
            pSmpl.cpuUsagePerc = perc * 0.01
        } else {
            NSLog("%@", "Could not read cpu value: \(percStr)")
        }

        pSmpl.xstat = getFromLine(line, titleKey: "XSTAT", transform: {Int($0)})
        //pSmpl.stat = getFromLine("STAT", transform: {FSProcessSample});
        pSmpl.signalsPending = getFromLine(line, titleKey: "PENDING", transform: {$0})
        pSmpl.signalsBlocked = getFromLine(line, titleKey: "BLOCKED", transform: {$0})

        assert(pSmpl.cpuUsagePerc != nil)
        assert(pSmpl.staticDat.exec != nil)

        return pSmpl
    }
    var staticDats = [Int : FSProcessSampleStatic]()
    private func staticDatFromLine(line: [FSString]) -> FSProcessSampleStatic {

        let pid = getFromLine(line, titleKey: "PID", transform: {Int($0)!})
        let command = getFromLine(line, titleKey: "COMMAND", transform: {$0})

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
        let (p, e, a) = splitCommand(line[titleMap["COMMAND"]!])
        staticDat.executionPath = p
        staticDat.exec = e
        staticDat.executionArguments = a

        // command parsing end

        staticDat.user = getFromLine(line, titleKey: "USER", transform: {$0})

        staticDat.ppid = getFromLine(line, titleKey: "PPID", transform: {Int($0)})
        staticDat.pgid = getFromLine(line, titleKey: "PGID", transform: {Int($0)})
        staticDat.gid = getFromLine(line, titleKey: "GID", transform: {Int($0)})
        staticDat.uid = getFromLine(line, titleKey: "UID", transform: {Int($0)})
        staticDat.rgid = getFromLine(line, titleKey: "RGID", transform: {Int($0)})
        staticDat.ruid = getFromLine(line, titleKey: "RUID", transform: {Int($0)})
        staticDat.ruser = getFromLine(line, titleKey: "RUSER", transform: {$0})
        staticDat.startDate = getFromLine(
            line,
            titleKey: "STARTED",
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
    private func getFromLine(line: [FSString], titleKey: String) -> String? {
        return getFromLine(line, titleKey: titleKey, transform: {$0})
    }
    private func getFromLine<T>(line: [FSString], titleKey: String, transform: (String) -> T) -> T! {
        let index = titleMap[titleKey]
        return getVal(line, index: index, transform: transform)
    }

    private func getVal<T>(line: [FSString], index: Int!, transform: (String) -> T) -> T! {
        if index == nil {
            return nil
        }
        let str = line[index].string()
        return transform(str)
    }
}
