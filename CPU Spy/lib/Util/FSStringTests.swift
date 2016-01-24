//
//  FSStringTests.swift
//  CPU Spy
//
//  Created by Felice Serena on 19.12.15.
//  Copyright © 2015 Serena. All rights reserved.
//


import Cocoa
import XCTest

class FSStringTests: XCTestCase {
    func testIdentity() {
        let str : String = "hello World!";
        let myStr : FSString = FSString(str);
        let swiftStr : String = myStr.string();
        
        XCTAssertEqual(str, swiftStr, "FSString doesn't return a string equivalent to the swift string it has been constructed from.");
    }
    
    func testSubString(){
        let myStr : FSString = "Hello World!";
        let subStr : FSString = myStr.substring(6, aLength: 5);
        
        XCTAssertEqual("World", subStr.string());
    }
    
    func testFindNext(){
        let myStr : FSString = FSString("abcd aaabcdefg abcd").substring(5);
        let find = myStr.substring(myStr.findNext("abc"));
        
        XCTAssertEqual("abcdefg abcd", find.string());
    }
    func testComponentsSeparatedByStringNormal(){
        let myStr : FSString = "a,b,c,d,e";
        let arr = myStr.componentsSeparatedByString(",");
        
        let c = arr.count;
        var i = 0;
        XCTAssertEqual(5, c);
        XCTAssertEqual("a", arr[i++].string());
        XCTAssertEqual("b", arr[i++].string());
        XCTAssertEqual("c", arr[i++].string());
        XCTAssertEqual("d", arr[i++].string());
        XCTAssertEqual("e", arr[i++].string());
    }
    func testComponentsSeparatedByStringMassive(){
        let myStr : FSString = "abc";
        let arr = myStr.componentsSeparatedByString(",");
        
        let c = arr.count;
        var i = 0;
        XCTAssertEqual(1, c);
        XCTAssertEqual("abc", arr[i++].string());
    }
    func testComponentsSeparatedByStringEmpty(){
        let myStr : FSString = "";
        let arr = myStr.componentsSeparatedByString(",");
        
        let c = arr.count;
        XCTAssertEqual(0, c);
    }
    func testComponentsSeparatedByStringEmptyBorder(){
        let myStr : FSString = ",a,b,c,";
        let arr = myStr.componentsSeparatedByString(",");
        
        let c = arr.count;
        var i = 0;
        XCTAssertEqual(5, c);
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("a", arr[i++].string());
        XCTAssertEqual("b", arr[i++].string());
        XCTAssertEqual("c", arr[i++].string());
        XCTAssertEqual("", arr[i++].string());
    }
    func testComponentsSeparatedByStringEmptyInbetween(){
        let myStr : FSString = ",a,,,c,";
        let arr = myStr.componentsSeparatedByString(",");
        
        let c = arr.count;
        var i = 0;
        XCTAssertEqual(6, c);
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("a", arr[i++].string());
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("c", arr[i++].string());
        XCTAssertEqual("", arr[i++].string());
    }
    func testComponentsSeparatedByStringWord(){
        let myStr : FSString = "abc123abcabc234abc";
        let arr = myStr.componentsSeparatedByString("abc");
        
        let c = arr.count;
        var i = 0;
        XCTAssertEqual(5, c);
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("123", arr[i++].string());
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("234", arr[i++].string());
        XCTAssertEqual("", arr[i++].string());
    }
    func testComponentsSeparatedByStringWordIncomplete(){
        let myStr : FSString = "abc123abcabc234ab";
        let arr = myStr.componentsSeparatedByString("abc");
        
        let c = arr.count;
        var i = 0;
        XCTAssertEqual(4, c);
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("123", arr[i++].string());
        XCTAssertEqual("", arr[i++].string());
        XCTAssertEqual("234ab", arr[i++].string());
    }
    
    func testTrimNone(){
        let trimmed = FSString("abc").trim(Set(arrayLiteral: ASCII.space.rawValue));
        XCTAssertEqual("abc", trimmed.string());
    }
    
    func testTrimLeftRight(){
        let trimmed = FSString("    abc    ").trim(Set(arrayLiteral: ASCII.space.rawValue));
        XCTAssertEqual("abc", trimmed.string());
    }
    func testTrimAll(){
        let trimmed = FSString("        ").trim(Set(arrayLiteral: ASCII.space.rawValue));
        XCTAssertEqual("", trimmed.string());
    }
}