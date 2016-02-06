//
//  FSSample.swift
//  CPU Spy
//
//  Created by Felice Serena on 4.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation

/*
    Models the state of all processes at a single point in time.
*/

public class FSSample: Sample {
    // FAQ: why arrays and not linked lists? it's simpler for maintaining

    /// time when sample was taken
    public internal(set) var dateSampling: NSDate = NSDate()

    /// raw data
    public private(set) var processesAll: [ProcessSample] = []


    // MARK: Methods
    // MARK: wrapper: appending to lists
    internal func appendProcessSample(newProc: ProcessSample) {
        // insert into global list
        processesAll.append(newProc)
    }

    public var totalCpuUsagePercAll: Double {
        get {
            var sum = 0.0
            for p in processesAll {
                sum += p.cpuUsagePerc
            }
            return sum
        }
    }
}
