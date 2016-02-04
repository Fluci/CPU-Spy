//
//  FSPSCommandSplitter.swift
//  CPU Spy
//
//  Created by Felice Serena on 18.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

/**
 Analyses a command (like in command line within a console/terminal) and 
 splits it to path, executable name and arguments array.
 */

public class FSPSCommandSplitter: CommandSplitter {

    private let commandArgsUpperBounds: [FSString] = [" --", " /", " ./"]

    private func argSureUpperBound(command: FSString ) -> Int {

        var argsStart = command.length
        for u in commandArgsUpperBounds {
            argsStart = min(argsStart, command.findNext(u))
        }
        return argsStart
    }

    public func split(command: FSString) -> (path: FSString?, exec: FSString, args: [FSString]) {

        var argStart = argSureUpperBound(command)
        let execStart = command.substring(0, aLength: argStart).findPrev(ASCII.Slash.rawValue)+1
        var space = command.findNext(ASCII.Space.rawValue, start: execStart)
        let argStartTmp = argStart-1
        while space < argStartTmp {
            assert(command[space] == ASCII.Space.rawValue)
            let nextLetter = command[space+1]
            if !(ASCII.UpperA.rawValue <= nextLetter && nextLetter <= ASCII.UpperZ.rawValue) {
                argStart = min(argStart, space+1)
                break
            }
            space = command.findNext(ASCII.Space.rawValue, start: space + 1)
        }

        let path: FSString?
        let exec: FSString

        if execStart > 0 {
            path = command.substring(0, aLength: execStart-1).trim(ASCII.Space.rawValue)
        } else {
            path = nil
        }
        exec = command
            .substring(execStart, aLength: argStart - execStart)
            .trim(ASCII.Space.rawValue)
        let argsStr: FSString
        if argStart < command.length {
            argsStr = command.substring(argStart).trim(ASCII.Space.rawValue)
        } else {
            argsStr = FSString()
        }

        let args: [FSString] = argsStr.componentsSeparatedByString(" ")

        return (path: path, exec: exec, args: args)
    }

}
