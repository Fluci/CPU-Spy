//
//  IconSample.swift
//  CPU Spy
//
//  Created by Felice Serena on 24.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public protocol IconSample: Icon {
    /// how many samples (bars) to show
    var maxSamples: Int { get set }

    /// how many cores does the measured machine posses?
    var cores: Int { get set }

    /// how many processes should be listed explicitly?
    var entries: Int { get set }

    /// how many "subbars" should be displayed in bars (1 subbar corresponds to one processSample)
    var barPeek: Int { get set }

    var barColor: [String : FSPriorityColors] { get set }

    var font: CTFontRef { get set }

    var username: String { get set }

    /// in which order should the partitions be displayed? valid partitions: system, user, other
    var partitionsOrder: [String] { get set }

    /// sets all values such that the Icon can be redrawn
    func addSample(smpl: Sample)
}
