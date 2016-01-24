//
//  FSSampler.swift
//  CPU Spy
//
//  Created by Felice Serena on 4.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation

public class FSSampler: NSObject, Sampler {
    /// measured in seconds [s]
    public var sampleInterval: Double = 5.0 {
        didSet {
            if sampleInterval < 0 {
                // this should never be called,
                // since it's the UI's responsibility to check the values
                NSLog("Warning, tried to set sampleInterval to %f, changed to 1.0.", sampleInterval)
                sampleInterval = 1.0
            }
            if !samplingActivated || samplingInProgress {
                return
            }
            if oldValue == sampleInterval {
                /* do nothing: trivial case */
                return
            }
            let passedTime = oldValue - samplingTimer.fireDate.timeIntervalSinceNow
            if passedTime > oldValue {
                // that means the fireDate is in the past
                // which means something went wrong (race condition)
                NSLog("encountered fireDate in the past while samplingActivated but not in progress, restarting sampling")
                stop()
                run()
                start()
            }
            if sampleInterval > passedTime {
                // make sure next-last = new
                // fire-point is in the future and has to be taken closer
                stop()
                startIn(sampleInterval - passedTime)
                return
            }
            if sampleInterval <= passedTime {
                // updated fire point was in past, timer has to be fired now
                // trigger now
                stop()
                run()
                start()
            }
        }
    }

    public private(set) var samplingActivated = false
    public private(set) var samplingInProgress = false

    public var delegate: SamplerDelegate?

    public private(set) var sample: Sample?

    internal func setNewSample(newSample: Sample) {
        sample = newSample
        delegateDidLoadSample(newSample)
    }


    private var samplingTimer = NSTimer()

    /// starts the sampling
    public func start () {
        startIn(sampleInterval)
        // trigger first sample now
        run()
    }
    internal func startIn(interval: NSTimeInterval) {
        samplingActivated = true
        samplingTimer = NSTimer.scheduledTimerWithTimeInterval(
            interval,
            target: self,
            selector: Selector("run"),
            userInfo: nil,
            repeats: true)
    }
    /// stops the sampling
    func stop () {
        if !samplingActivated {
            return
        }
        samplingActivated = false
        samplingTimer.invalidate()
    }

    deinit {
        if samplingActivated {
            stop()
        }
    }

    public func run() {
        if !samplingActivated {
            NSLog("called run with samplingActivated = false, not taking sample")
            return
        }
        if samplingInProgress {
            NSLog("last sampling is still running, skipping this sample")
            return
        }
        samplingInProgress = true
        sampleNow()
        samplingInProgress = false
    }

    /// has to be overwritten by child
    internal func sampleNow () {
        preconditionFailure("sampleNow must be overwritten")
    }

    /// informs delegate
    private func delegateDidLoadSample(sample: Sample) {
        self.delegate?.didLoadSample(self, sample: sample)
    }

}
