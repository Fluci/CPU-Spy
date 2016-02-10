//
//  FSPSTokenizer.swift
//  CPU Spy
//
//  Created by Felice Serena on 06.02.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

enum RangeWideningError: ErrorType {
    case NoFit
}

final class FSPSTokenizer: Tokenizer {
    private var cols: [PSCol]!

    private var lineStart = -1
    private var lineEnd = -1

    var psOutput = FSString()
    private(set) var activeLine = FSString()

    private(set) var headerStr = FSString()
    private(set) var header = [FSString]()

    func readHeader() throws -> [FSString] {
        lineStart = 0
        lineEnd = psOutput.findNext(ASCII.NewLine.rawValue, start: lineStart)

        if cols != nil {
            lineStart = lineEnd+1
            return header
        }

        let bStart = lineEnd+1
        let bEnd = psOutput.findNext(ASCII.NewLine.rawValue, start: bStart)

        headerStr = psOutput.substring(lineStart, aLength: lineEnd - lineStart)
        let bodyString = psOutput.substring(bStart, aLength: bEnd - bStart)

        cols = getColsFromLines(headerStr, bodyLine: bodyString)

        lineStart = lineEnd+1

        // cols created
        header = try rowFromLine(headerStr)

        return header
    }

    func hasNext() -> Bool {
        return lineEnd < psOutput.length
    }

    func readNextRow() throws -> [FSString]! {

        lineEnd = psOutput.findNext(ASCII.NewLine.rawValue, start: lineStart)
        activeLine = psOutput.substring(lineStart, aLength: lineEnd - lineStart)

        lineStart = lineEnd+1
        do {
            return try rowFromLine(activeLine)
        } catch RangeWideningError.NoFit {
            throw RangeWideningError.NoFit
        }
    }

    // MARK: cols-specific
    private func stringifyCols(cols: [PSCol]) -> String {
        var out = ""
        var lastSym = -1
        for r in cols {
            for _ in lastSym+1..<r.start {
                out += " " // space between ranges
            }

            out += "S"; // rangeStart
            var end = r.end
            if r.end == Int.max {
                end = r.start+10
            }
            for _ in r.start+1..<end {
                out += "_" // space in range
            }
            out += "E"; // rangeEnd
            lastSym = r.end
        }

        return out
    }

    private func colsFromLine(let line: FSString) -> [PSCol] {
        var cols = [PSCol]()

        if line.isEmpty {
            return cols
        }

        var start: Int

        let lineLen = line.length

        var i = 0

        while i < lineLen && line[i] == ASCII.Space.rawValue {
            // find first non space character
            i += 1
        }
        start = i

        while i < lineLen {
            i = line.findNext(ASCII.Space.rawValue, start: i); // iterate over title characters

            cols.append(PSCol(start: start, end: i))

            i = line.findNextUneq(ASCII.Space.rawValue, start: i); // iterate over spaces
            start = i
            i += 1
        }

        cols[0].start = 0
        cols[cols.count-1].end = Int.max
        return cols
    }

    private func widenColsWithLine(aLine: FSString, var cols: [PSCol]) throws -> [PSCol] {
        // widen range according to new knowledge

        if cols.isEmpty {
            return cols
        }

        for i in 1..<cols.count {
            let pInd = i-1; // index of predecessor
            let c = cols[i]; // active range
            let p = cols[pInd]; // predecessor range

            if p.end + 1 == c.start {
                // exact border
                continue
            }
            if c.alignment == .Right && p.alignment == .Right {
                // predecessor is right-aligned
                cols[i].start = p.end + 1
                continue
            }
            if c.alignment == .Left {
                // this is left-aligned
                assert(p.alignment != .Right)
                cols[pInd].end = c.start - 1
                continue
            }
            if c.alignment == .Right && p.alignment == .Left {
                // we need to check the data of the line we're looking at to at least widen the range
                var end = p.end
                var start = c.start
                while aLine[end] != ASCII.Space.rawValue {end += 1}
                while aLine[start] != ASCII.Space.rawValue {start -= 1}
                if end >= start {
                    NSLog("Anomaly in %@ for indexes %d to %d", aLine.string(), start, end)
                    throw RangeWideningError.NoFit
                }

                // apply widening
                cols[i].start = start
                cols[pInd].end = end
            }
            // you could think of fancier analysis at this point
            // but that is left as an exercise to the future me if it's necessary
        }

        // clean up cols.last which has been modified by each rowRead
        if cols[cols.count-1].end != Int.max {
            cols[cols.count-1].end = Int.max
        }

        return cols
    }

    private func findAlignment(var cols: [PSCol], headLine: FSString, bodyLine: FSString) -> [PSCol] {

        // we know that start and end of the range correspond to the start and end of the headerline
        // assumption: two or more spaces are a clear signal that one of them is a border between two cols
        // assumption: if the end col and the start col of two neighbours differ by 1, they are exact
        // we only look at the cols with a predecessor, so we look only at the space between this and its predecessor

        if cols.isEmpty {
            return cols
        }

        for i in 0..<cols.count {
            let c = cols[i]
            if .Unknown != c.alignment {
                continue
            }
            let lastColInd = cols.count-1

            // simple cases: if there's a space directly under the first or last letter of the title, alignment-deduction is easy
            if bodyLine[c.start] == ASCII.Space.rawValue {
                // right-aligned
                assert(i == lastColInd || ASCII.Space.rawValue != bodyLine[c.end-1])
                assert(i == lastColInd || ASCII.Space.rawValue == bodyLine[c.end], bodyLine.string())
                cols[i].alignment = .Right
                continue
            }
            if i < lastColInd && bodyLine[c.end-1] == ASCII.Space.rawValue {
                // left-aligned
                assert(ASCII.Space.rawValue != bodyLine[c.start])
                assert(i == 0 || ASCII.Space.rawValue == bodyLine[c.start-1])
                cols[i].alignment = .Left
                continue
            }
            // well, there are no spaces directly beyond
            // lets check the letters right before the start and right after the end
            if i > 0 && bodyLine[c.start-1] != ASCII.Space.rawValue {
                // right-aligned
                cols[i].alignment = .Right
                continue
            }
            if i < lastColInd && bodyLine[c.end] != ASCII.Space.rawValue {
                // left-aligned
                cols[i].alignment = .Left
                continue
            }
            // now we know: (X: a letter, _: a space)
            //      TITLE     TITLE  |
            //     _X   X_           |
            // in this case we need to look at the neighbours

            // think about left neighbour-distances
            if i > 0 && cols[i - 1].end + 1 == c.start {
                cols[i].alignment = .Left
                continue
            }
            // just keep it unknown
        }

        // apply knowledge of special cases

        if cols[0].alignment == .Unknown
            && (headLine[0] == ASCII.Space.rawValue || bodyLine[0] == ASCII.Space.rawValue) {
                cols[0].alignment = .Right
        }


        // let's look at the neighbours for alignment deduction
        for i in 0..<cols.count {
            let c = cols[i]

            if c.alignment != .Unknown {
                continue
            }
            if i > 0              && .Right == cols[i-1].alignment && cols[i-1].end + 1 < c.start {
                // the predecessor is right-aligned and I have distance larger than the minimum
                // => right-aligned
                cols[i].alignment = .Right
                continue
            }
            if i < cols.count - 1 && .Left == cols[i+1].alignment && c.end + 1 < cols[i+1].start {
                // the next is left-aligned and this has a distance larger than the minimum
                // => left-aligned
                cols[i].alignment = .Left
                continue
            }
        }
        return cols
    }

    internal func getColsFromLines(headLine: FSString, bodyLine: FSString) -> [PSCol] {

        var cols: [PSCol] = colsFromLine(headLine)

        cols = findAlignment(cols, headLine: headLine, bodyLine: bodyLine)

        do {
            try cols = widenColsWithLine(bodyLine, cols: cols)
        } catch RangeWideningError.NoFit {
            NSLog("Could not widen range with line: %@", bodyLine.string())
        } catch {
            NSLog("Unexpected exception caught.")
        }
        return cols
    }


    // MARK: explode psOutput line into cells
    /**
    @param ranges expects all range values to exist (e.g. ranges.last!.end == line.length)
    */
    func rowFromLine(let line: FSString) throws -> [FSString] {
        var row = [FSString]()

        if cols.isEmpty {
            return row
        }

        cols[cols.count-1].end = line.length

        row.reserveCapacity(cols.count)

        for i in 0..<cols.count {
            var start = cols[i].start
            var end = cols[i].end

            if (0 < start && line[start-1] != ASCII.Space.rawValue)
                || (end < line.length && line[end] != ASCII.Space.rawValue) {
                    try cols = self.widenColsWithLine(line, cols: cols)

                    start = cols[i].start
                    end = cols[i].end

                    if (0 < start && line[start-1] != ASCII.Space.rawValue)
                        || (end < line.length && line[end] != ASCII.Space.rawValue) {
                            NSLog("Updating cols failed: %@", line.string())
                            throw RangeWideningError.NoFit
                    }

            }
            if 0 < i && start - cols[i-1].end > 1 {
                // there's a gap, make sure it's empty
                var empty = true
                for t in cols[i-1].end..<start {
                    if line[t] != ASCII.Space.rawValue {
                        empty = false
                        break
                    }
                }
                if !empty {
                    NSLog("special gap \"%@\" in line between %d and %d in %@",
                        line.substring(
                            cols[i-1].end,
                            aLength: start - cols[i-1].end
                            ).string(),
                        start, end, line.string())
                }
            }

            let cell = line.substring(start, aLength: end - start)
            let trimmedCell = cell.trim(ASCII.Space.rawValue)
            row.append(trimmedCell)
        }
        return row
    }
}