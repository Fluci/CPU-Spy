//
//  FSPSSamplerTests.swift
//  CPU Spy
//
//  Created by Felice Serena on 19.12.15.
//  Copyright © 2015 Serena. All rights reserved.
//

import Foundation


import Cocoa
import XCTest

class FSPSSamplerTests: XCTestCase {
    func testGetRangesCase1() {
        /*
        |00000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455
        |012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
        |  PID  %CPU  PPID  PGID   GID   UID USER             RGID  RUID RUSER           STARTED                      STAT XSTAT  PENDING  BLOCKED   SESS COMMAND
        |  482  19.1     1   482    20   501 feliceserena       20   501 feliceserena    Thu Dec 17 22:57:11 2015     S        0        0        0      0 /Applications/Feeds/Vienna.app/Contents/MacOS/Vienna -psn_0_135201
        */
        let headerLine: FSString = "  PID  %CPU  PPID  PGID   GID   UID USER             RGID  RUID RUSER           STARTED                      STAT XSTAT  PENDING  BLOCKED   SESS COMMAND"
        let bodyLine: FSString = "  482  19.1     1   482    20   501 feliceserena       20   501 feliceserena    Thu Dec 17 22:57:11 2015     S        0        0        0      0 /Applications/Feeds/Vienna.app/Contents/MacOS/Vienna -psn_0_135201"
        let tokenizer = FSPSTokenizer()
        let ranges = tokenizer.getColsFromLines(headerLine, bodyLine: bodyLine)

        XCTAssertEqual(17, ranges.count)
        var i = 0

        // PID
        XCTAssertEqual(0, ranges[i].start)
        XCTAssertEqual(5, ranges[i].end)
        i += 1

        // %CPU
        XCTAssertEqual(6, ranges[i].start)
        XCTAssertEqual(11, ranges[i].end)
        i += 1

        // PPID
        XCTAssertEqual(12, ranges[i].start)
        XCTAssertEqual(17, ranges[i].end)
        i += 1

        // PGID
        XCTAssertEqual(18, ranges[i].start)
        XCTAssertEqual(23, ranges[i].end)
        i += 1

        // GID
        XCTAssertEqual(24, ranges[i].start)
        XCTAssertEqual(29, ranges[i].end)
        i += 1

        // UID
        XCTAssertEqual(30, ranges[i].start)
        XCTAssertEqual(35, ranges[i].end)
        i += 1

        // USER
        XCTAssertEqual(36, ranges[i].start)
        XCTAssertEqual(48, ranges[i].end)
        i += 1

        // undecidable

        // RGID
        XCTAssertEqual(53, ranges[i].start)
        XCTAssertEqual(57, ranges[i].end)
        i += 1

        // RUID
        XCTAssertEqual(58, ranges[i].start)
        XCTAssertEqual(63, ranges[i].end)
        i += 1

        // RUSER
        XCTAssertEqual(64, ranges[i].start)
        XCTAssertEqual(79, ranges[i].end)
        i += 1

        // STARTED
        XCTAssertEqual(80, ranges[i].start)
        XCTAssertEqual(108, ranges[i].end)
        i += 1

        // undecidable

        // STAT
        XCTAssertEqual(109, ranges[i].start)
        XCTAssertEqual(113, ranges[i].end)
        i += 1

        // XSTAT
        XCTAssertEqual(114, ranges[i].start)
        XCTAssertEqual(119, ranges[i].end)
        i += 1

        // PENDING
        XCTAssertEqual(120, ranges[i].start)
        XCTAssertEqual(128, ranges[i].end)
        i += 1

        // BLOCKED
        XCTAssertEqual(129, ranges[i].start)
        XCTAssertEqual(137, ranges[i].end)
        i += 1

        // SESS
        XCTAssertEqual(138, ranges[i].start)
        XCTAssertEqual(144, ranges[i].end)
        i += 1

        // COMMAND
        XCTAssertEqual(145, ranges[i].start)
        XCTAssertEqual(Int.max, ranges[i].end)
        i += 1

    }
    func testGetRangesCase2() {
        /*
        |00000000001111111111222
        |01234567890123456789012
        |  PID  %CPU  PPID  PGID
        |49555  23.0     1 49555
        */
        let headerLine: FSString = "  PID  %CPU  PPID  PGID"
        let bodyLine: FSString = "49555  23.0     1 49555"

        let tokenizer = FSPSTokenizer()
        let ranges = tokenizer.getColsFromLines(headerLine, bodyLine: bodyLine)

        XCTAssertEqual(4, ranges.count)
        var i = 0
        // PID
        XCTAssertEqual(0, ranges[i].start)
        XCTAssertEqual(5, ranges[i].end)
        i += 1

        // %CPU
        XCTAssertEqual(6, ranges[i].start)
        XCTAssertEqual(11, ranges[i].end)
        i += 1

        // PPID
        XCTAssertEqual(12, ranges[i].start)
        XCTAssertEqual(17, ranges[i].end)
        i += 1

        // PGID
        XCTAssertEqual(18, ranges[i].start)
        XCTAssertEqual(Int.max, ranges[i].end)
        i += 1
    }
    func testGetRangesCase3() {
        /*
        |000000000011111111112222222222333333333344444444445555555
        |012345678901234567890123456789012345678901234567890123456
        |  PID  %CPU  PPID  PGID   GID   UID USER             RGID
        |  575   0,0     1   575   200   200 _softwareupdate   200
        */
        let headerLine: FSString = "  PID  %CPU  PPID  PGID   GID   UID USER             RGID"
        let bodyLine: FSString = "  575   0,0     1   575   200   200 _softwareupdate   200"
        let tokenizer = FSPSTokenizer()
        let ranges = tokenizer.getColsFromLines(headerLine, bodyLine: bodyLine)

        XCTAssertEqual(8, ranges.count)
        var i = 0

        // PID
        XCTAssertEqual(0, ranges[i].start)
        XCTAssertEqual(5, ranges[i].end)
        i += 1

        // %CPU
        XCTAssertEqual(6, ranges[i].start)
        XCTAssertEqual(11, ranges[i].end)
        i += 1

        // PPID
        XCTAssertEqual(12, ranges[i].start)
        XCTAssertEqual(17, ranges[i].end)
        i += 1

        // PGID
        XCTAssertEqual(18, ranges[i].start)
        XCTAssertEqual(23, ranges[i].end)
        i += 1

        // GID
        XCTAssertEqual(24, ranges[i].start)
        XCTAssertEqual(29, ranges[i].end)
        i += 1

        // UID
        XCTAssertEqual(30, ranges[i].start)
        XCTAssertEqual(35, ranges[i].end)
        i += 1

        // USER
        XCTAssertEqual(36, ranges[i].start)
        XCTAssertEqual(51, ranges[i].end)
        i += 1

        // undecidable

        // RGID
        XCTAssertEqual(53, ranges[i].start)
        XCTAssertEqual(Int.max, ranges[i].end)
        i += 1
    }
    func testSharedStr() {
        let full: FSString = "123456789"
        let part = full.substring(1, aLength: 6)

        XCTAssertEqual("234567", part.string())

        part[1] = ASCII.Space.rawValue
        full[5] = ASCII.Space.rawValue
        full[7] = ASCII.Space.rawValue

        // check wether they really share a common string
        XCTAssertEqual("2 45 7", String(part))
        XCTAssertEqual("12 45 7 9", String(full))
    }
}
