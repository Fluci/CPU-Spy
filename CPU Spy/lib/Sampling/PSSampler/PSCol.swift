//
//  FSPSCol.swift
//  CPU Spy
//
//  Created by Felice Serena on 19.12.15.
//  Copyright © 2015 Serena. All rights reserved.
//

import Foundation

enum Alignment {
    case Left
    case Right
    case Unknown
}

internal struct PSCol {
    var start: Int = 0
    var end: Int = Int.max
    var alignment: Alignment = .Unknown

    init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}
