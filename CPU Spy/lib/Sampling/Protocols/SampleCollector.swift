//
//  SampleCollector.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public protocol SampleCollector {
    
    init(aSampler : Sampler)
    
    var delegate : SampleCollectorDelegate? { get set }
    var sampler : Sampler { get }
    
    var samples : [Sample] { get }
    
    var maxSamples : Int { get set }
}