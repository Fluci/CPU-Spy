//
//  ProcessSampleStatic.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public protocol ProcessSampleStatic {
    /// executing binary; substring of executionPath
    var exec : String! { get }
    
    /// executionpath to execution binary (binary exclusive); substring of command
    var executionPath : String! { get }
    
    var executionArguments : [String]! { get }
    
    /// command-line to start app (executionPath + arguments)
    var command : String! { get }
    
    var commandComments : [String]! { get }
    var bundle : String! { get }
    
    var pid     : Int! { get }
    var ppid    : Int! { get }
    var gid     : Int! { get }
    var pgid    : Int! { get }
    var uid     : Int! { get }
    var user    : String! { get }
    
    var rgid    : Int! { get }
    var ruid    : Int! { get }
    var ruser   : String! { get }
    
    var sessionId : Int! { get }
    
    var startDate : NSDate! { get }
}