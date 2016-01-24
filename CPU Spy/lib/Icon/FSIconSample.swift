//
//  FSIconSample.swift
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa

public class FSIconSample : FSIcon, IconSample {
    /// how many samples (bars) to show
    public var maxSamples : Int = 16
    
    public var cores : Int = 1
    
    /// how many processes should be listed explicitly?
    public var entries : Int = 7

    /// how many "subbars" should be displayed in bars (1 subbar corresponds to one processSample)
    public var barPeek : Int = 2
    
    public var barColor  : [String : FSPriorityColors] = [
        "system" : FSPriorityColors(aDefaultColor: [0.8, 0.3, 0.3, 1.0], somePrioColors: [1.0, 0.0, 0.0, 1.0], [0.9, 0.0, 0.0, 1.0]),
        "user"   : FSPriorityColors(aDefaultColor: [0.3, 0.8, 0.3, 1.0], somePrioColors: [0.0, 1.0, 0.0, 1.0], [0.0, 0.9, 0.0, 1.0]),
        "other"  : FSPriorityColors(aDefaultColor: [0.3, 0.3, 0.8, 1.0], somePrioColors: [0.0, 0.0, 1.0, 1.0], [0.0, 0.0, 0.9, 1.0]),
        "all"    : FSPriorityColors(aDefaultColor: [1.0, 1.0, 1.0, 1.0])
        ]
    
    public var font : CTFontRef = CTFontCreateWithName("Menlo Regular", 10.0, nil)
    
    private var strAttributes : [String : [String : AnyObject]] {
        get {
            return [
                "system" : [
                    NSForegroundColorAttributeName: CGColorCreate(rgbColorSpace, barColor["system"]![0])!,
                    NSFontAttributeName: font
                ],
                "user" : [
                    NSForegroundColorAttributeName: CGColorCreate(rgbColorSpace, barColor["user"]![0])!,
                    NSFontAttributeName: font
                ],
                "other" : [
                    NSForegroundColorAttributeName: CGColorCreate(rgbColorSpace, barColor["other"]![0])!,
                    NSFontAttributeName: font
                ],
                "all" : [
                    NSForegroundColorAttributeName: CGColorCreate(rgbColorSpace, barColor["all"]![0])!,
                    NSFontAttributeName: font
                ]
            ];
        }
    };
    
    private let rgbColorSpace : CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!;
    
    /// 2/cores (bar height is multiplied in the drawer)
    private var barScale : Double {
        get {
            return 1/Double(cores);
        }
    }
    
    /// samples to display textually
    private var lines : ArraySlice<ProcessSample>!;
    public var username = "aUser";
    public var partitionsOrder = ["system", "user", "other"]
    private let pSmplValSelector : (ProcessSample) -> Double = {$0.cpuUsagePerc}
    private let pSmplPartitionKey : (ProcessSample) -> String = {
        switch $0.staticDat.user {
        case "root":
            return "system"
        case "feliceserena":
            return "user"
        default:
            return "other"
        }
    }
    private let pSmplDisplayName : (ProcessSample) -> String = {$0.staticDat.exec}

    /// sets all values such that the Icon can be redrawn
    public func addSample(smpl : Sample){
        let pSmpls = smpl.processesAll.filter {self.pSmplValSelector($0) != 0.0}.sort {self.pSmplValSelector($0) > self.pSmplValSelector($1)};
        
        // get lines
        let str : CFMutableAttributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        CFAttributedStringBeginEditing(str) // turn off internal checking
        /// keep track of string starts to give them the appropriate format
        var start = 0;
        let len = min(entries, pSmpls.count);
        for var i = 0; i < len; i++ {
            let pSmpl : ProcessSample = pSmpls[i];
            let line = padStringLeft(self.pSmplValSelector(pSmpl)*100, positions: 5) + " " + self.pSmplDisplayName(pSmpl) + "\n"
            let len = line.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
            let range = CFRangeMake(start, 0)
            start = start + len
            
            let attr = [
                NSForegroundColorAttributeName: CGColorCreate(rgbColorSpace, barColor[self.pSmplPartitionKey(pSmpl)]![i])!,
                NSFontAttributeName: font
            ];
            
            let addStr = CFAttributedStringCreate(kCFAllocatorDefault, line, attr)
            
            
            CFAttributedStringReplaceAttributedString(str, range, addStr)
        }
        CFAttributedStringEndEditing(str)
        drawer.text = str
        
        
        // repartition
        
        let pSmplsPartition : [String : [ProcessSample]] = partition(pSmpls){self.pSmplPartitionKey($0)}
        
        // place partitions in order in the list
        var orderedPartitions = [[ProcessSample]]();
        
        var cellsLocal = [CFAttributedString]()
        // reduce partions to the values that should be displayed and add to cells
        cellsLocal.append(CFAttributedStringCreate(kCFAllocatorDefault, "", nil));
        var sum = 0.0;
        for orderKey in partitionsOrder {
            if let p = pSmplsPartition[orderKey] {
                let value : Double = p.reduce(0.0){(l : Double, r) in l + self.pSmplValSelector(r)}*100;
                sum += value;
                let attr = [
                    NSForegroundColorAttributeName: CGColorCreate(rgbColorSpace, barColor[orderKey]![0])!,
                    NSFontAttributeName: font
                ]
                let attrStr : CFAttributedString = CFAttributedStringCreate(kCFAllocatorDefault, padStringLeft(value, positions: 5), attr);
                cellsLocal.append(attrStr);
                
                orderedPartitions.append(p);
            }
        }
        cellsLocal[0] = CFAttributedStringCreate(kCFAllocatorDefault, padStringLeft(sum, positions: 5), strAttributes["all"]);
        
        
        drawer.cells = cellsLocal;
        // decide here on color of cells
        
        // get bars
        var bar = [FSIconBar]();
        let scale = barScale * Double(drawer.height);
        for (var i = 0; i < orderedPartitions.count; ++i) {
            let pSmpls : [ProcessSample] = orderedPartitions[i]
            let max = min(pSmpls.count, barPeek);
            var p : Int;
            var subBar : FSIconBar;
            var sum : Double = 0.0;
            for(p = 0; p < max; ++p){
                let val : Double = self.pSmplValSelector(pSmpls[p]);
                sum += val;
                subBar = FSIconBar(aHeight: CGFloat(val*scale));
                // set color of bar
                subBar.color = barColor[pSmplPartitionKey(pSmpls[p])]![p];
                bar.append(subBar);
            }
            var rest = 0.0;
            for(; p < pSmpls.count; ++p){
                let val : Double = self.pSmplValSelector(pSmpls[p]);
                rest += val;
            }
            if(rest > 0){
                subBar = FSIconBar(aHeight: CGFloat(rest*scale));
                // set color of bar
                subBar.color = barColor[pSmplPartitionKey(pSmpls[0])]!.defaultColor;
                bar.append(subBar);
            }
        }
        if(drawer.bars.count >= maxSamples){
            // remove oldest
            for(var i = maxSamples-1; i < drawer.bars.count; ++i){
                drawer.bars.removeFirst()
            }
        } else if(drawer.bars.count+1 < maxSamples) {
            for(var i = drawer.bars.count+1; i < maxSamples; ++i){
                drawer.bars.append([]);
            }
        }
        drawer.bars.append(bar);
        assert(drawer.bars.count == maxSamples);
    }

    private func partition<T, K: Hashable>(arr : [T], keySelector: (T) -> K) -> [K : [T]]{
        var map = [K: [T]]();
        for e in arr {
            let mapKey = keySelector(e)
            if(map[mapKey] == nil){
                map[mapKey] = [T]();
            }
            map[mapKey]!.append(e);
        }
        return map
    }
    
    private func padStringLeft(aVal: Double, positions: Int) -> String{
        let str = String(stringInterpolationSegment: aVal)
        
        let diff = positions - str.characters.count;
        
        if(diff <= 0) {
            return str;
        }
        return String(count: diff, repeatedValue: Character(" ")) + str;
    }
}