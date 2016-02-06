//
//  File.swift
//  CPU Spy
//
//  Created by Felice Serena on 4.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation

private enum RangeWideningError: ErrorType {
    case NoFit
}

/**
    Sample implementation using the unix command ps as data source.
    The command gets split in a table (a two dimensional array of Strings)
    and then parsed by the rowReader. 
 */

public class FSPSSampler: FSSampler {

    private let lstartFormatter = NSDateFormatter()
    private let lstartCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    private let timeComponentsTmp = NSDateComponents()

    // MARK: task-coordination
    private(set) var waitingForTaskToFinish = false

    lazy private var task = NSTask()
    lazy private var pipe = NSPipe()

    // MARK: sample-data
    private var buffer = FSString()

    private var cols: [PSCol]!

    /// Maps col name to index in row
    private var titleMap: [String : Int]!

    let rowReader: FSPSRowReader

    // MARK: init
    init (aRowReader: FSPSRowReader = FSPSRowReader()) {
        rowReader = aRowReader
        super.init()
        lstartFormatter.timeStyle = .NoStyle
        lstartFormatter.dateStyle = .NoStyle
        lstartFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        lstartFormatter.dateFormat = "E MMM dd HH:mm:ss yyyy"
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "taskTerminated:",
            name: NSFileHandleDataAvailableNotification,
            object: nil)
    }

    // MARK: ps-coordination
    override internal func sampleNow () {
        if waitingForTaskToFinish {
            // just return if the previous task hasn't finished yet
            return
        }
        // launches the task
        runPs()
    }
    private func runPs() {
        task = NSTask()
        pipe = NSPipe()

        task.launchPath = "/bin/ps"
        // binary -> is cached after first call
        // TODO: find API

        // ww: causes the lines not to stop at the end of the screen
        // but to wrap to the next line (at least in terminal view)
        task.arguments = ["-Arww", "-o pid,%cpu,ppid,pgid,gid,uid,user,rgid,ruid,ruser,lstart,state,xstat,sig,sigmask,sess,command"]

        task.standardOutput = pipe

        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()

        waitingForTaskToFinish = true // flag

        task.launch()

    }

    /*
    a Note on ps options:

    -A: show all (not exactly, but closest)
    -o: specific cols, with colheader (or not, see man)
    -r: sort by current CPU usage
    -----------------------
    -f:
    uid, pid, parent pid,
    recent CPU usage, process start time,
    controlling tty, elapsed CPU usage,
    associated command
    -j: user, pid, ppid, pgid, sess, jobc, state, tt, time, and command
    -l: uid, pid, ppid, flags, cpu, pri, nice, vsz=SZ, rss, wchan, state=S, paddr=ADDR, tty, time, and command=CMD
    -v: (implies -m: sort by mem-size) pid, state, time, sl, re, pagein, vsz, rss, lim, tsiz, %cpu, %mem, and command
    ----------------
    ps -Arc -o %cpu,state,user,command: traditional output
    ps -Arc -o %cpu,state,user,command=CMMMMD: renames COMMAND-col to CMMMMD
    ps -Ar -o %cpu,state,user,command
    --------------
    needed ones:
    pid: for signaling
    command: identification
    user: sys-user grouping
    %cpu: main point of application
    state: for SIGCONT (T) info
    interesting:
    ppid, flags, lstart(<-start), ruid, ruser, time=cputime,etime, utime=putime, cpu (in test always 0), xstat
    --------------
    all keywords: see man ps

    */

    public func taskTerminated(aNotification: NSNotification) {
        // we're called by notification centre, the task did terminate and we can read the buffer

        if !waitingForTaskToFinish {
            NSLog("Unexpected message received … %@", aNotification.description)
            return
        }
        if aNotification.object !== pipe.fileHandleForReading {
            NSLog("Msg doesn't belong to pipe … %@", aNotification.description)
            return
        }
        waitingForTaskToFinish = false

        // process sample
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let bufferStr = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
        buffer = FSString(bufferStr)

        // trim end of psOutput
        var trimmedEnd = buffer.length-1
        while buffer[trimmedEnd] == ASCII.NewLine.rawValue
            || buffer[trimmedEnd] == ASCII.Space.rawValue {
                trimmedEnd -= 1
        }
        buffer = buffer.substring(0, aLength: trimmedEnd)

        let smpl = newSampleFromPsOutput(buffer)
        setNewSample(smpl)
    }

    // MARK: Read psOutput

    private func newSampleFromPsOutput(psOutput: FSString) -> FSSample {
        // create cols and titleMap
        var lineStart = 0
        var lineEnd = psOutput.findNext(ASCII.NewLine.rawValue, start: lineStart)

        if nil == cols {

            let bStart = lineEnd+1
            let bEnd = psOutput.findNext(ASCII.NewLine.rawValue, start: bStart)

            let headerString = psOutput.substring(lineStart, aLength: lineEnd - lineStart)
            let bodyString = psOutput.substring(bStart, aLength: bEnd - bStart)

            cols = getColsFromLines(headerString, bodyLine: bodyString)
            // cols created

            titleMap = [String : Int]()
            // create titleMap
            do {
                let header: [FSString] = try rowFromLine(headerString)
                for index in 0..<header.count {
                    titleMap[header[index].string()] = index
                }
                // titleMap created
                rowReader.titleMap = titleMap
            } catch {
                // this really shouldn't happen
                NSLog("Failed to read header row form line: %@", headerString.string())
            }
        }

        // read processSamples
        let smpl = FSSample()

        lineStart = lineEnd+1

        while lineStart < psOutput.length {
            lineEnd = psOutput.findNext(ASCII.NewLine.rawValue, start: lineStart)
            let strLine = psOutput.substring(lineStart, aLength: lineEnd - lineStart)
            do {
                let line = try rowFromLine(strLine)

                let pSmpl = rowReader.readRow(line)
                smpl.appendProcessSample(pSmpl)
            } catch RangeWideningError.NoFit {
                NSLog("Line could not be read: %@", strLine.string())
            } catch {
                NSLog("Unexpected exception.")
            }

            lineStart = lineEnd+1
        }

        // rowFromLine changes cols[cols.count-1].end = line.length
        cols[cols.count-1].end = Int.max

        return smpl
    }

    // MARK: cols-specific
    private func stringifyCols(cols: [PSCol]) -> String {
        var out = ""
        var lastSym = -1
        for r in cols {
            for _ in lastSym+1..<r.start {
                out += " " // space between ranges
            }

            out += "S"; // rangeStart
            var end = r.end
            if r.end == Int.max {
                end = r.start+10
            }
            for _ in r.start+1..<end {
                out += "_" // space in range
            }
            out += "E"; // rangeEnd
            lastSym = r.end
        }

        return out
    }

    private func colsFromLine(let line: FSString) -> [PSCol] {
        var cols = [PSCol]()

        var start: Int

        let lineLen = line.length

        var i = 0

        while i < lineLen && line[i] == ASCII.Space.rawValue {
            // find first non space character
            i += 1
        }
        start = i

        while i < lineLen {
            i = line.findNext(ASCII.Space.rawValue, start: i); // iterate over title characters

            cols.append(PSCol(start: start, end: i))

            i = line.findNextUneq(ASCII.Space.rawValue, start: i); // iterate over spaces
            start = i
            i += 1
        }

        cols[0].start = 0
        cols[cols.count-1].end = Int.max
        return cols
    }

    private func widenColsWithLine(aLine: FSString, var cols: [PSCol]) throws -> [PSCol] {
        // widen range according to new knowledge

        for i in 1..<cols.count {
            let pInd = i-1; // index of predecessor
            let c = cols[i]; // active range
            let p = cols[pInd]; // predecessor range

            if p.end + 1 == c.start {
                // exact border
                continue
            }
            if c.alignment == .Right && p.alignment == .Right {
                // predecessor is right-aligned
                cols[i].start = p.end + 1
                continue
            }
            if c.alignment == .Left {
                // this is left-aligned
                assert(p.alignment != .Right)
                cols[pInd].end = c.start - 1
                continue
            }
            if c.alignment == .Right && p.alignment == .Left {
                // we need to check the data of the line we're looking at to at least widen the range
                var end = p.end
                var start = c.start
                while aLine[end] != ASCII.Space.rawValue {end += 1}
                while aLine[start] != ASCII.Space.rawValue {start -= 1}
                if end >= start {
                    NSLog("Anomaly in %@ for indexes %d to %d", aLine.string(), start, end)
                    throw RangeWideningError.NoFit
                }

                // apply widening
                cols[i].start = start
                cols[pInd].end = end
            }
            // you could think of fancier analysis at this point
            // but that is left as an exercise to the future me if it's necessary
        }
        return cols
    }

    private func findAlignment(var cols: [PSCol], headLine: FSString, bodyLine: FSString) -> [PSCol] {

        // we know that start and end of the range correspond to the start and end of the headerline
        // assumption: two or more spaces are a clear signal that one of them is a border between two cols
        // assumption: if the end col and the start col of two neighbours differ by 1, they are exact
        // we only look at the cols with a predecessor, so we look only at the space between this and its predecessor

        for i in 0..<cols.count {
            let c = cols[i]
            if .Unknown != c.alignment {
                continue
            }
            let lastColInd = cols.count-1

            // simple cases: if there's a space directly under the first or last letter of the title, alignment-deduction is easy
            if bodyLine[c.start] == ASCII.Space.rawValue {
                // right-aligned
                assert(i == lastColInd || ASCII.Space.rawValue != bodyLine[c.end-1])
                assert(i == lastColInd || ASCII.Space.rawValue == bodyLine[c.end], bodyLine.string())
                cols[i].alignment = .Right
                continue
            }
            if i < lastColInd && bodyLine[c.end-1] == ASCII.Space.rawValue {
                // left-aligned
                assert(ASCII.Space.rawValue != bodyLine[c.start])
                assert(i == 0 || ASCII.Space.rawValue == bodyLine[c.start-1])
                cols[i].alignment = .Left
                continue
            }
            // well, there are no spaces directly beyond
            // lets check the letters right before the start and right after the end
            if i > 0 && bodyLine[c.start-1] != ASCII.Space.rawValue {
                // right-aligned
                cols[i].alignment = .Right
                continue
            }
            if i < lastColInd && bodyLine[c.end] != ASCII.Space.rawValue {
                // left-aligned
                cols[i].alignment = .Left
                continue
            }
            // now we know: (X: a letter, _: a space)
            //      TITLE     TITLE  |
            //     _X   X_           |
            // in this case we need to look at the neighbours

            // think about left neighbour-distances
            if i > 0 && cols[i - 1].end + 1 == c.start {
                cols[i].alignment = .Left
                continue
            }
            // just keep it unknown
        }

        // apply knowledge of special cases

        if cols[0].alignment == .Unknown
            && (headLine[0] == ASCII.Space.rawValue || bodyLine[0] == ASCII.Space.rawValue) {
            cols[0].alignment = .Right
        }


        // let's look at the neighbours for alignment deduction
        for i in 0..<cols.count {
            let c = cols[i]

            if c.alignment != .Unknown {
                continue
            }
            if i > 0              && .Right == cols[i-1].alignment && cols[i-1].end + 1 < c.start {
                // the predecessor is right-aligned and I have distance larger than the minimum
                // => right-aligned
                cols[i].alignment = .Right
                continue
            }
            if i < cols.count - 1 && .Left == cols[i+1].alignment && c.end + 1 < cols[i+1].start {
                // the next is left-aligned and this has a distance larger than the minimum
                // => left-aligned
                cols[i].alignment = .Left
                continue
            }
        }
        return cols
    }

    internal func getColsFromLines(headLine: FSString, bodyLine: FSString) -> [PSCol] {

        var cols: [PSCol] = colsFromLine(headLine)

        cols = findAlignment(cols, headLine: headLine, bodyLine: bodyLine)

        do {
            try cols = widenColsWithLine(bodyLine, cols: cols)
        } catch RangeWideningError.NoFit {
            NSLog("Could not widen range with line: %@", bodyLine.string())
        } catch {
            NSLog("Unexpected exception caught.")
        }
        return cols
    }

    // MARK: explode psOutput line into cells
    /**
    @param ranges expects all range values to exist (e.g. ranges.last!.end == line.length)
    */
    private func rowFromLine(let line: FSString) throws -> [FSString] {
        var row = [FSString]()

        cols[cols.count-1].end = line.length

        row.reserveCapacity(cols.count)

        for i in 0..<cols.count {
            var start = cols[i].start
            var end = cols[i].end

            if (0 < start && line[start-1] != ASCII.Space.rawValue)
                || (end < line.length && line[end] != ASCII.Space.rawValue) {
                try cols = self.widenColsWithLine(line, cols: cols)

                start = cols[i].start
                end = cols[i].end

                if (0 < start && line[start-1] != ASCII.Space.rawValue)
                    || (end < line.length && line[end] != ASCII.Space.rawValue) {
                    NSLog("updating cols failed: %@", line.string())
                    continue
                }

            }
            if 0 < i && start - cols[i-1].end > 1 {
                // there's a gap, make sure it's empty
                var empty = true
                for t in cols[i-1].end..<start {
                    if line[t] != ASCII.Space.rawValue {
                        empty = false
                        break
                    }
                }
                if !empty {
                    NSLog("special gap \"%@\" in line between %d and %d in %@",
                        line.substring(
                            cols[i-1].end,
                            aLength: start - cols[i-1].end
                            ).string(),
                        start, end, line.string())
                }
            }

            let cell = line.substring(start, aLength: end - start)
            let trimmedCell = cell.trim(ASCII.Space.rawValue)
            row.append(trimmedCell)
        }
        return row
    }
}
