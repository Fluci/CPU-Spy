//
//  ProcessState
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation


public enum ProcessState : Int {
    case normal             // just nothing special
    case idle               // I
    case runnable           // R
    case sleeping           // S
    case stopped            // T
    case uninterruptible    // U
    case zombie             // Z
}
