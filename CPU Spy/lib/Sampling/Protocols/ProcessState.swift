//
//  ProcessState
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation


public enum ProcessState: Int {
    case Normal             // just nothing special
    case Idle               // I
    case Runnable           // R
    case Sleeping           // S
    case Stopped            // T
    case Uninterruptible    // U
    case Zombie             // Z
}
