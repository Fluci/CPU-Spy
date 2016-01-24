//
//  Sample.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public protocol Sample {
    var dateSampling  : NSDate { get };
    
    /// raw data
    var processesAll : [ProcessSample] { get };
    
    var totalCpuUsagePercAll : Double { get };
}