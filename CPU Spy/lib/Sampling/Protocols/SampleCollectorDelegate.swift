//
//  SampleCollectorDelegate.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public protocol SampleCollectorDelegate {
    func didLoadSample(sender: SampleCollector, sample: Sample);
}
