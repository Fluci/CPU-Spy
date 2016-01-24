//
//  ProcessSample.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public protocol ProcessSample {
    var staticDat : ProcessSampleStatic { get }
    
    /// 1.0 = one core running on 100%
    var cpuUsagePerc : Double! { get }
    var memUsagePerc : Double! { get }
    
    var signalsPending : String! { get }
    var signalsBlocked : String! { get }
    
    var xstat : Int! { get }
    var state : ProcessState! { get }
    var additionalStates : [ProcessStateAdditional] { get }
    
    
    func addAdditionalState(s: ProcessStateAdditional);
    
}