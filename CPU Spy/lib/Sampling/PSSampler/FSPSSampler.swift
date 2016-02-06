//
//  File.swift
//  CPU Spy
//
//  Created by Felice Serena on 4.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation

/**
    Sample implementation using the unix command ps as data source.
    The command gets split in a table (a two dimensional array of Strings)
    and then parsed by the rowReader. 
 */

final public class FSPSSampler: FSSampler {

    private let lstartFormatter = NSDateFormatter()
    private let lstartCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    private let timeComponentsTmp = NSDateComponents()

    // MARK: task-coordination
    private(set) var waitingForTaskToFinish = false

    lazy private var task = NSTask()
    lazy private var pipe = NSPipe()

    // MARK: sample-data
    private var buffer = FSString()

    /// Maps col name to index in row
    private var titleMap: [String : Int]!

    private var rowReader: RowReader
    private var tokenizer: Tokenizer

    // MARK: init
    init (aRowReader: RowReader = FSPSRowReader(), aTokenizer: Tokenizer = FSPSTokenizer()) {
        rowReader = aRowReader
        tokenizer = aTokenizer
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
    -l: uid, pid, ppid, flags, cpu, pri, nice, vsz=SZ, rss, wchan, 
        state=S, paddr=ADDR, tty, time, and command=CMD
    -v: (implies -m: sort by mem-size) pid, state, time, sl, re, pagein, 
        vsz, rss, lim, tsiz, %cpu, %mem, and command
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
    ppid, flags, lstart(<-start), ruid, ruser, time=cputime,etime, 
        utime=putime, cpu (in test always 0), xstat
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
        do {
            let smpl = try newSampleFromPsOutput(buffer)
            setNewSample(smpl)
        } catch {
            NSLog("Error encountered, skipping sample.")
        }
    }

    // MARK: Read psOutput

    private func newSampleFromPsOutput(psOutput: FSString) throws -> FSSample {
        // create cols and titleMap

        tokenizer.psOutput = psOutput
        let header: [FSString]
        do {
            header = try tokenizer.readHeader()
        } catch let e {
            // this really shouldn't happen
            NSLog("Failed to read header row form line: %@", tokenizer.headerStr.string())
            throw e
        }

        if nil == titleMap {

            titleMap = [String : Int]()
            // create titleMap
                for index in 0..<header.count {
                    titleMap[header[index].string()] = index
                }
                // titleMap created
                rowReader.titleMap = titleMap

        }

        // read processSamples
        let smpl = FSSample()

        while tokenizer.hasNext() {
            do {
                let line = try tokenizer.readNextRow()

                let pSmpl = try rowReader.readRow(line)
                smpl.appendProcessSample(pSmpl)
            } catch RangeWideningError.NoFit {
                NSLog("Line could not be read: %@", tokenizer.activeLine.string())
            } catch ReaderError.NoPid {
                NSLog("No pid found: %@", tokenizer.activeLine.string())
            } catch {
                NSLog("Unexpected exception.")
            }
        }

        return smpl
    }

}
