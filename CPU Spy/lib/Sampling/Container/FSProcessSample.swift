//
//  FSProcessSample.swift
//  CPU Spy
//
//  Created by Felice Serena on 7.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation



public class FSProcessSample: ProcessSample {
    public internal(set) var staticDat: ProcessSampleStatic = FSProcessSampleStatic()

    public internal(set) var cpuUsagePerc: Double! // 1.0 = one core running on 100%
    public internal(set) var memUsagePerc: Double!

    public internal(set) var signalsPending: String!
    public internal(set) var signalsBlocked: String!

    public internal(set) var xstat: Int!
    public internal(set) var state: ProcessState!
    public private(set) var additionalStates: [ProcessStateAdditional] = []


    public func addAdditionalState(aState: ProcessStateAdditional) {
        additionalStates.append(aState)
    }

}
