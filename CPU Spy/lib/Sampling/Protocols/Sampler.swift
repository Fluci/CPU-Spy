//
//  Sampler.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public protocol Sampler {
    var sampleInterval: Double { get set }
    var delegate: SamplerDelegate? { get set }
    var sample: Sample? { get }

    func start ()
}
