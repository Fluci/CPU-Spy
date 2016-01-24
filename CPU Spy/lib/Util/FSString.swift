//
//  FSString.swift
//  CPU Spy
//
//  Created by Felice Serena on 19.12.15.
//  Copyright © 2015 Serena. All rights reserved.
//

import Foundation

public enum ASCII: CChar {
    case Null = 0
    case NewLine = 10
    case Space = 32
    case Slash = 47
    case UpperA = 65
    case UpperZ = 90
    case Backslash = 92
}

public final class FSString:
    CustomStringConvertible,
    CustomDebugStringConvertible,
    StringLiteralConvertible {

    var str: UnsafeMutablePointer<[CChar]>

    // MARK: subStr
    var rangeStart: Int

    // always rangeStart + length
    var rangeEnd: Int {
        get {
            return rangeStart + length
        }
    }

    public var description: String {
        return self.string()
    }
    public var debugDescription: String {
        return self.string()
    }

    // not the absolute length of str, but the substring that should be accessible to the client
    public private(set) var length: Int

    // MARK: Book-keeping
    // reference count
    var rfc: UnsafeMutablePointer<Int>

    // MARK: init
    init() {
        rfc = UnsafeMutablePointer<Int>.alloc(1)
        rfc.initialize(1)

        str = UnsafeMutablePointer<[CChar]>.alloc(1);//[ASCII.null.rawValue];
        str.initialize([CChar]())
        str.memory.append(ASCII.Null.rawValue)

        rangeStart = 0
        length = 0
        //rfc.initialize(1);
    }

    public typealias UnicodeScalarLiteralType = Character
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: String(value))
    }

    public convenience init(
        extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    public convenience init(_ aString: String) {
        self.init(stringLiteral: aString)
    }
    public required init(stringLiteral aString: String) {
        rfc = UnsafeMutablePointer<Int>.alloc(1)
        rfc.initialize(1)

        let buffLen = aString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)+1
        str = UnsafeMutablePointer<[CChar]>.alloc(1)
        str.initialize([CChar](count: buffLen, repeatedValue: ASCII.Null.rawValue))
        aString.getCString(&str.memory, maxLength: buffLen, encoding: NSUTF8StringEncoding)

        rangeStart = 0
        length = str.memory.count - 1
        assert(length >= 0)

    }
    private init(
        aStr: UnsafeMutablePointer<[CChar]>,
        aRfc: UnsafeMutablePointer<Int>,
        aRangeStart: Int,
        aLength: Int) {
        str = aStr
        rangeStart = aRangeStart
        length = aLength
        rfc = aRfc
    }
    deinit {
        --rfc.memory
        if rfc.memory == 0 {
            str.destroy()
            str.dealloc(1)

            rfc.destroy()
            rfc.dealloc(1)
        }
    }
    // MARK: access
    subscript(index: Int) -> Int8 {
        get {
            assert(index < length)
            return str.memory[index + rangeStart]
        }
        set(newValue) {
            assert(index < length)
            str.memory[index + rangeStart] = newValue
        }
    }
    public var first: CChar! {
        get {
            if length == 0 {
                return nil
            }
            return str.memory[rangeStart]
        }
    }
    public var last: CChar! {
        get {
            if length == 0 {
                return nil
            }
            return str.memory[rangeEnd-1]
        }
    }
    public func substring(start: Int, var aLength: Int = Int.max) -> FSString {
        assert(0 <= aLength)
        if 0 == aLength {
            return FSString()
        }
        assert(start < length)


        //rfc[0]++
        let childStart = rangeStart + start
        aLength = min(aLength, length - start)

        ++rfc.memory

        let child = FSString(
            aStr: str,
            aRfc: rfc,
            aRangeStart: childStart,
            aLength: aLength)
            //aRfc: rfc)

        assert(child.length == aLength)
        assert(rangeStart <= child.rangeStart)
        assert(child.rangeEnd <= rangeEnd)

        return child
    }
    public func string() -> String {
        var subStr: [CChar] = Array(str.memory[rangeStart...rangeEnd])
        subStr[length] = ASCII.Null.rawValue
        let swiftStr = String.fromCString(subStr)!
        return swiftStr
    }

    public func componentsSeparatedByString(needle: FSString) -> [FSString] {
        var array = [FSString]()
        if 0 == length {
            return array
        }
        var start = 0
        var end: Int = 0
        while end < length {
            end = findNext(needle, start: start)
            array.append(self.substring(start, aLength: end - start))
            start = end + needle.length
        }
        return array
    }

    // MARK: findNext
    /**
        @return start of needle or length if not found
    */
    public func findNext(needle: FSString, start: Int = 0) -> Int {
        let firstChar = needle[0]
        var i: Int
        for i = start; i < length; ++i {
            i = findNext(firstChar, start: i)
            if i == length {
                // no match
                break
            }

            var j: Int
            let cI = rangeStart + i; // constant
            for j = 1; j < needle.length; ++j {
                if str.memory[cI + j] != needle[j] || i + j == length {
                    break
                }
            }
            if j == needle.length {
                // found
                break
            }
            // not found, keep searching

            // self-reminder:
            // this optimization is not possible,
            // since the needle could be in the just searched string
            // i = i + j
        }
        return i
    }

    public func findNext(needle: Set<CChar>, start: Int = 0) -> Int {
        if needle.count == 0 {
            return length
        }
        if needle.count == 1 {
            return findNext(needle.first!, start: start)
        }
        return findNext(start) {needle.contains($0)}
    }
    /**
    @return index of next occurence of needle needle or length if not found
    */
    public func findNext(needle: CChar, start: Int = 0) -> Int {
        return findNext(start) {$0 == needle}
    }
    public func findNextUneq(needle: CChar, start: Int = 0) -> Int {
        return findNext(start) {$0 != needle}
    }
    // main findNext function
    public func findNext(start: Int = 0, isMatch: (CChar) -> Bool) -> Int {
        var pos: Int = start + rangeStart
        let s = str.memory
        while pos < rangeEnd && !isMatch(s[pos]) {
            ++pos
        }
        return pos - rangeStart
    }

    // MARK: findPrev
    public func findPrev(needle: Set<CChar>, start: Int = -1) -> Int {
        if needle.count == 0 {
            return -1
        }
        if needle.count == 1 {
            return findPrev(needle.first!, start: start)
        }
        return findPrev(start) {needle.contains($0)}
    }
    public func findPrev(needle: CChar, start: Int = -1) -> Int {
        return findPrev(start) {$0 == needle}
    }
    // main findPrev-function
    public func findPrev(var start: Int = -1, isMatch: (CChar) -> Bool) -> Int {
        if start == -1 {
            start = self.length - 1
        }
        var pos = start + rangeStart

        while rangeStart <= pos && !isMatch(str.memory[pos]) {
            --pos
        }

        return pos - rangeStart
    }

    // MARK: trim
    public func trim(trimChars: Set<CChar>) -> FSString {
        if trimChars.count == 1 {
            return trim(trimChars.first!)
        } else if trimChars.count == 0 {
            return self.substring(0, aLength: length)
        }
        var start: Int
        var end: Int
        for end = length-1; -1 < end; --end {
            if !trimChars.contains(self[end]) {
                break
            }
        }
        ++end
        for start = 0; start < end; ++start {
            if !trimChars.contains(self[start]) {
                break
            }
        }
        if start >= end {
            return FSString()
        }
        let trimmedString = self.substring(start, aLength: end - start)
        return trimmedString
    }

    public func trim(trimChar: CChar) -> FSString {
        var start: Int
        var end: Int
        let rStart = rangeStart
        for end = rStart + length-1; rStart <= end; --end {
            if trimChar != str.memory[end] {
                break
            }
        }
        ++end
        for start = rStart; start < end; ++start {
            if trimChar != str.memory[start] {
                break
            }
        }
        if start >= end {
            return FSString()
        }
        return substring(start - rStart, aLength: end - start)
    }
}
