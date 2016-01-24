//
//  FSPSCommandSplitter.swift
//  CPU Spy
//
//  Created by Felice Serena on 18.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

public class FSPSCommandSplitter : CommandSplitter {
    
    private let commandArgsUpperBounds : [FSString] = [" --", " /", " ./"];
    /**
    expected patterns: "< path >/< exec > < args >", "< exec > < args >" with unmasked spaces in path, exec and args
    */
    private func argSureUpperBound(command : FSString ) -> Int {
        
        var argsStart = command.length;
        for u in commandArgsUpperBounds {
            argsStart = min(argsStart, command.findNext(u));
        }
        return argsStart;
    }
    
    public func split(command : FSString) -> (path : FSString?, exec : FSString, args : [FSString]) {
        
        var argStart = argSureUpperBound(command);
        let execStart = command.substring(0, aLength: argStart).findPrev(ASCII.slash.rawValue)+1;
        var space = command.findNext(ASCII.space.rawValue, start: execStart);
        let argStartTmp = argStart-1;
        while(space < argStartTmp){
            assert(command[space] == ASCII.space.rawValue);
            let nextLetter = command[space+1];
            if(!(ASCII.upperA.rawValue <= nextLetter && nextLetter <= ASCII.upperZ.rawValue)){
                argStart = min(argStart, space+1);
                break;
            }
            space = command.findNext(ASCII.space.rawValue, start: space + 1);
        }
        
        let path : FSString?;
        let exec : FSString;
        
        if(execStart > 0){
            path = command.substring(0, aLength: execStart-1).trim(ASCII.space.rawValue);
        } else {
            path = nil;
        }
        exec = command.substring(execStart, aLength: argStart - execStart).trim(ASCII.space.rawValue);
        let argsStr : FSString;
        if(argStart < command.length){
            argsStr = command.substring(argStart).trim(ASCII.space.rawValue);
        } else {
            argsStr = FSString();
        }
        
        let args : [FSString] = argsStr.componentsSeparatedByString(" ");

        return (path: path, exec: exec, args: args);
    }

}