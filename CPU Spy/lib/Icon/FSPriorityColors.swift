//
//  FSPriorityColors.swift
//  CPU Spy
//
//  Created by Felice Serena on 25.12.15.
//  Copyright © 2015 Serena. All rights reserved.
//

import Foundation


public class FSPriorityColors {
    public var defaultColor: [CGFloat]
    public var prioColors: [[CGFloat]]

    public subscript(index: Int) -> [CGFloat] {
        if 0 <= index && index < prioColors.count {
            return prioColors[index]
        }
        return defaultColor
    }

    init(aDefaultColor: [CGFloat] = [0.5, 0.5, 0.5, 1.0], somePrioColors: [CGFloat]...) {
        defaultColor = aDefaultColor
        prioColors = somePrioColors
    }
}
