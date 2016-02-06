//
//  ProcessStateAdditional.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public enum ProcessStateAdditional: Int {
    case Normal                 // just nothing special
    case Foreground             // +
    case RaisedCPU              // <
    case ExceedingSoftMemLim    // >
    case RandomPageReplacement  // A
    case Exiting                // E
    case LockedPagesInCore      // L
    case ReducedCPUPriority     // N
    case FIFOPageReplacement    // S
    case SessionLeader          // s
    case VforkSuspension        // V
    case SwappedOut             // W
    case TracedDebugged         // X
}
