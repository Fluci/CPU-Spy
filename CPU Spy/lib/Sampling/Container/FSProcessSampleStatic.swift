
//
//  FSProcessSampleStatic.swift
//  CPU Spy
//
//  Created by Felice Serena on 28.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation

public class FSProcessSampleStatic : ProcessSampleStatic {
    /// executing binary; substring of executionPath
    public internal(set) var exec : String!
    
    /// executionpath to execution binary (binary exclusive); substring of command
    public internal(set) var executionPath : String!
    
    public internal(set) var executionArguments : [String]!
    
    // command-line to start app (executionPath + arguments)
    public internal(set) var command : String!
    
    public internal(set) var commandComments : [String]!
    public internal(set) var bundle : String!
    
    public internal(set) var pid     : Int!
    public internal(set) var ppid    : Int!
    public internal(set) var gid     : Int!
    public internal(set) var pgid    : Int!
    public internal(set) var uid     : Int!
    public internal(set) var user    : String!
    
    public internal(set) var rgid    : Int!
    public internal(set) var ruid    : Int!
    public internal(set) var ruser   : String!
    
    public internal(set) var sessionId : Int!
    
    public internal(set) var startDate : NSDate!
}