//
//  FSSampleCollector.swift
//  CPU Spy
//
//  Created by Felice Serena on 13.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation

/**
 Highest level within the model. At the moment, this is mainly a placeholder.
 It is intended to work accross multiple samples.
 Possible use cases might be the linking of processSamples to linked lists or
 analysis of the data within time.
*/

public class FSSampleCollector: SampleCollector, SamplerDelegate {

    public required init (aSampler: Sampler) {
        sampler = aSampler
        sampler.delegate = self
    }

    public var delegate: SampleCollectorDelegate?
    public private(set) var sampler: Sampler

    public private(set) var samples: [Sample] = []
    public var maxSamples: Int = 16

    // MARK: internal
    private func addSample(smpl: Sample) {
        if samples.count >= maxSamples {
            samples.removeFirst(maxSamples - samples.count + 1)
            assert(samples.count == maxSamples-1)
        }
        samples.append(smpl)
        assert(samples.count <= maxSamples)
    }

    // MARK: interfaces for communication with subobjects

    private func delegateDidLoadSample(sample: Sample) {
        // informs delegate
        self.delegate?.didLoadSample(self, sample: sample)
    }

    // MARK: delegate-receiving

    public func didLoadSample(sender: Sampler, sample: Sample) {
        addSample(sample)
        delegateDidLoadSample(sample)
    }

}
