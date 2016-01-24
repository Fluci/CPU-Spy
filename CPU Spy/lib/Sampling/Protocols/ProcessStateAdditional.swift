//
//  ProcessStateAdditional.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public enum ProcessStateAdditional : Int {
    case normal                 // just nothing special
    case foreground             // +
    case raisedCPU              // <
    case exceedingSoftMemLim    // >
    case randomPageReplacement  // A
    case exiting                // E
    case lockedPagesInCore      // L
    case reducedCPUPriority     // N
    case FIFOPageReplacement    // S
    case sessionLeader          // s
    case vforkSuspension        // V
    case swappedOut             // W
    case tracedDebugged         // X
}