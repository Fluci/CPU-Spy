//
//  FSPSRowReaderTests.swift
//  CPU Spy
//
//  Created by Felice Serena on 18.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

import Cocoa
import XCTest
/**
    All cases are run in `testAll()`, the other tests are a demonstration that the special cases work.
    Don't change the order of the cases in the array, just append at the end.
*/
class FSPSCommandSplitterTests: XCTestCase {
    
    let splitter : CommandSplitter = FSPSCommandSplitter();
    
    func testNoPath() {
        runCase(8);
        runCase(9);
        runCase(10);
        runCase(12);
        runCase(13);
    }
    func testNoArgs(){
        runCase(14);
        runCase(16);
    
    }
    func testCommonAll(){
        runCase(12);
        runCase(13);
    }
    func testSpecialArgSpaceExec(){
        runCase(16);
        runCase(17);
        runCase(18);
    }
    func testSpecialArgLowArg(){
        runCase(3);
        runCase(5);
        runCase(6);
        runCase(7);
    }
    func testSpecialArgPath(){
        runCase(0);
        runCase(1);
        runCase(2);
    }
    func testAll(){
        for(var i = 0; i < cases.count; ++i){
            runCase(i);
        }
    }
    func runCase(let i : Int){
        let c = cases[i];
        let (path: path, exec: exec, args: args) = splitter.split(FSString(c.command));
        
        XCTAssertEqual(c.path, path?.string(), "case \(i) failed: path: \(c.command)");
        XCTAssertEqual(c.exec, exec.string(), "case \(i) failed: exec: \(c.command)");
        XCTAssertEqual(c.args.count, args.count, "case \(i) failed: args: \(c.command)");
        let m = min(c.args.count, args.count);
        for(var j = 0; j < m; ++j){
            XCTAssertEqual(c.args[j], args[j].string(), "case \(i) failed: arg \(j): \(c.command)");
        }
    }
    
    let cases : [(command : String, path : String?, exec: String, args: [String])] = [
        ( // 0
            command: "/opt/cisco/anyconnect/bin/vpnagentd -execv_instance",
            path: "/opt/cisco/anyconnect/bin",
            exec: "vpnagentd",
            args: ["-execv_instance"]
        ),
        ( // 1
            command: "/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd-helper -launchd",
            path: "/System/Library/CoreServices/backupd.bundle/Contents/Resources",
            exec: "backupd-helper",
            args: ["-launchd"]
        ),
        ( // 2
            command: "/System/Library/CoreServices/CrashReporterSupportHelper server-init",
            path: "/System/Library/CoreServices",
            exec: "CrashReporterSupportHelper",
            args: ["server-init"]
        ),
        ( // 3
            command: "/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow console",
            path: "/System/Library/CoreServices/loginwindow.app/Contents/MacOS",
            exec: "loginwindow",
            args: ["console"]
        ),
        ( // 4
            command: "/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Versions/A/Support/mdworker -s mdworker -c MDSImporterWorker -m com.apple.mdworker.shared",
            path: "/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Versions/A/Support",
            exec: "mdworker",
            args: ["-s", "mdworker", "-c", "MDSImporterWorker", "-m", "com.apple.mdworker.shared"]
        ),
        ( // 5
            command: "/System/Library/PrivateFrameworks/TCC.framework/Resources/tccd system",
            path: "/System/Library/PrivateFrameworks/TCC.framework/Resources",
            exec: "tccd",
            args: ["system"]
        ),
        ( // 6
            command: "/usr/libexec/UserEventAgent (Aqua)",
            path: "/usr/libexec",
            exec: "UserEventAgent",
            args: ["(Aqua)"]
        ),
        ( // 7
            command: "/usr/sbin/cfprefsd agent",
            path: "/usr/sbin",
            exec: "cfprefsd",
            args: ["agent"]
        ),
        ( // 8
            command: "login -pf aUser",
            path: nil,
            exec: "login",
            args: ["-pf", "aUser"]
        ),
        ( // 9
            command: "ps -Ao command",
            path: nil,
            exec: "ps",
            args: ["-Ao", "command"]
        ),
        ( // 10
            command: "ssh -Cf -L localhost:15555:localhost:1234 abc@de.fg.de -p 4321 sleep 10",
            path: nil,
            exec: "ssh",
            args: ["-Cf", "-L", "localhost:15555:localhost:1234", "abc@de.fg.de", "-p", "4321", "sleep", "10"]
        ),
        ( // 11
            command: "/bin/sh - /usr/sbin/periodic daily",
            path: "/bin",
            exec: "sh",
            args: ["-", "/usr/sbin/periodic", "daily"]
        ),
        ( // 12
            command: "-sh",
            path: nil,
            exec: "-sh",
            args: []
        ),
        ( // 13
            command: "(clang)",
            path: nil,
            exec: "(clang)",
            args: []
        ),
        ( // 14
            command: "/Applications/chats/Skype.app/Contents/MacOS/Skype",
            path: "/Applications/chats/Skype.app/Contents/MacOS",
            exec: "Skype",
            args: []
        ),
        ( // 15
            command: "/Applications/Clouds/Dropbox.app/Contents/MacOS/Dropbox /firstrunupdate 743",
            path: "/Applications/Clouds/Dropbox.app/Contents/MacOS",
            exec: "Dropbox",
            args: ["/firstrunupdate", "743"]
        ),
        ( // 16
            command: "/Applications/CPU Spy.app/Contents/MacOS/CPU Spy",
            path: "/Applications/CPU Spy.app/Contents/MacOS",
            exec: "CPU Spy",
            args: []
        ),
        ( // 17
            command: "/Applications/Editoren/Taco HTML Edit 1.7.2/Taco HTML Edit.app/Contents/MacOS/Taco HTML Edit",
            path: "/Applications/Editoren/Taco HTML Edit 1.7.2/Taco HTML Edit.app/Contents/MacOS",
            exec: "Taco HTML Edit",
            args: []
        ),
        ( // 18
            command: "/Applications/Microsoft Office 2008/Office/Microsoft Database Daemon.app/Contents/MacOS/Microsoft Database Daemon",
            path: "/Applications/Microsoft Office 2008/Office/Microsoft Database Daemon.app/Contents/MacOS",
            exec: "Microsoft Database Daemon",
            args: []
        ),
        ( // 19
            command: "/Applications/Microsoft Office 2011/Office/Office365Service.app/Contents/MacOS/Office365Service",
            path: "/Applications/Microsoft Office 2011/Office/Office365Service.app/Contents/MacOS",
            exec: "Office365Service",
            args: []
        ),
        ( // 20
            command: "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Tools/XcodeDeviceMonitor --bonjour 123J4KL32L-LK4J23LK-234LKJ-234JKL2-K32J4LK23L1",
            path: "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Tools",
            exec: "XcodeDeviceMonitor",
            args: ["--bonjour", "123J4KL32L-LK4J23LK-234LKJ-234JKL2-K32J4LK23L1"]
        ),
        ( // 21
            command: "/bin/sh /usr/local/mysql/bin/mysqld_safe --user=mysql",
            path: "/bin",
            exec: "sh",
            args: ["/usr/local/mysql/bin/mysqld_safe", "--user=mysql"]
        ),
        ( // 22
            command: "/sbin/launchd",
            path: "/sbin",
            exec: "launchd",
            args: []
        ),
        ( // 23
            command: "/System/Library/CoreServices/Dock.app/Contents/XPCServices/com.apple.dock.extra.xpc/Contents/MacOS/com.apple.dock.extra",
            path: "/System/Library/CoreServices/Dock.app/Contents/XPCServices/com.apple.dock.extra.xpc/Contents/MacOS",
            exec: "com.apple.dock.extra",
            args: []
        )
    ];
}