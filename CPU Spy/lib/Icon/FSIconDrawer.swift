//
//  FSIconOptimizer.swift
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa

@objc public protocol FSIconDrawerDelegate : NSObjectProtocol {
    optional func willDraw(sender: FSIconDrawer)
    optional func didDraw(sender: FSIconDrawer)
    
    func willRedraw(sender: FSIconDrawer) -> Bool
}

/*
    concept:
    loop over bars array, drawing the low indexes at the bottom, high indexes at the top

*/

public class FSIconDrawer : NSObject {
    public private(set) var icon = NSImage();
    
    public var bars : [[FSIconBar]] = [] // drawn histogramm data
    public var cells : [CFAttributedString] = [] // first text line is subdivided in cells.count cells and filled with the content of the corresponding cell
    public var text : CFAttributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0) // the text displayed bellow the cells
    
    public var width  : CGFloat = 128.0 {
        didSet{
            updateImgSize()
        }
    }
    public var height : CGFloat = 128.0 {
        didSet{
            updateImgSize()
        }
    }
    
    public var cellsHeight : CGFloat = 11.0
    
    public var txtPaddingLeft : CGFloat = 1.0
    public var txtPaddingRight : CGFloat = 1.0
    public var txtPaddingInbetween : CGFloat = 1.0
    
    public var delegate : FSIconDrawerDelegate?
    
    // MARK: INIT
    
    override init () {
        super.init()
        updateImgSize()
        let myRep = NSCustomImageRep(drawSelector:Selector("drawIcon:") , delegate: self)
        icon.addRepresentation(myRep)
    }
    
    // MARK: drawIcon
    func updateImgSize(){
        icon.size = NSSize(width: width, height: height)
    }
    func drawIcon(anNSCustomImageRep : AnyObject){
        // time: O(iconSamplesCount); goal: O(newDataSets)
        // @Role: Performance critical
        
        // expects to be executed in a valid NSGraphicsContext
        // draws the iconImage
        // TODO: improve drawing by internal caching of the bars (save bars, load bars, move them by width of new input, draw new input, continue …)
        //NSLog("drawing icon ...")
        
        let lWidth  : CGFloat = width
        let lHeight : CGFloat = height
        
        delegateWillDraw()
        delegateWillRedraw()
        
        if(NSGraphicsContext.currentContext() == nil){
            NSLog("FSIconDrawer: no current NSGraphicContext");
            return
        }
        
        let ctx : CGContextRef = NSGraphicsContext.currentContext()!.CGContext
        
        // turn antialiasing off for energy save
        CGContextSetAllowsAntialiasing(ctx, false)
        CGContextSetShouldAntialias(ctx, false)
        
        // draw black background
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 1)
        CGContextFillRect(ctx, CGRectMake(0.0, 0.0, lWidth, lHeight))
        
        
        
        drawBars();
        drawText();
        drawCells();
        
        
        delegateDidDraw()
        
    }
    private func drawBars(){
        
        // run-variables
        
        var x : Int = 0
        var y : Int = 0
        
        let barsCount = bars.count
        var barCount = 0
        var bar : [FSIconBar]
        var b : FSIconBar
        
        // draw bars
        var barBase : CGFloat = 0.0 // lower horizontal edge y-coordinate
        var barHeight : CGFloat = 0.0 // height of bar
        var barStart : CGFloat = 0.0 // left vertical edge x-coordinate
        let barWidth : CGFloat = width / CGFloat(barsCount) // horizontal width
        
        
        // coordinate system: (0,0) left bottom corner
        
        let ctx : CGContextRef = NSGraphicsContext.currentContext()!.CGContext
        
        CGContextSetLineWidth(ctx, 0.0)

        for (x = 0; x < barsCount; x++) {
            bar = bars[x]
            barBase = 0.0
            barStart = barWidth * CGFloat(x) // leftStartPoint: calculated absolute for
            barCount = bar.count
            for (y = 0; y < barCount; y++) {
                b = bar[y]
                barHeight = b.height
                //CGContextSetFillColor(ctx, &b.color)
                CGContextSetRGBFillColor(ctx, b.color[0], b.color[1], b.color[2], 1)
                CGContextFillRect(ctx, CGRectMake(barStart, barBase, barWidth, barHeight))
                barBase = barBase + barHeight
            }
        }
        assert(barHeight <= height)
    }
    private func drawCells(){
        let cellCount = cells.count
        let cellWidth : CGFloat = (width - txtPaddingLeft - txtPaddingRight - txtPaddingInbetween*CGFloat(cellCount-1))/CGFloat(cellCount)
        let cellHeight = height
        var cell : CFAttributedString
        
        
        // optimization of start calculation: 
        //   CGFloat(i)* cellWidth + txtPaddingInbetween*CGFloat(i) + txtPaddingLeft
        // = CGFloat(i)*(cellWidth + txtPaddingInbetween)           + txtPaddingLeft
        // a * CGFloat(i) + b
        let a = cellWidth + txtPaddingInbetween
        let b = txtPaddingLeft
        
        let ctx : CGContextRef = NSGraphicsContext.currentContext()!.CGContext
        
        // run vars
        var i = 0
        var txtRect : NSRect = NSRect(x: 0.0, y: 0.0, width: cellWidth*4, height: cellHeight)
        var txtPath : CGMutablePathRef
        let emptyRange = CFRangeMake(0, 0)
        
        var framesetter : CTFramesetterRef
        var frame : CTFrameRef
        
        //var lFont : CTFontRef = font // localize
        
        
        for (i = 0; i < cellCount; i++) {
            cell = cells[i]

            // left-start of cell
            txtRect.origin.x = CGFloat(i)*a + b
            
            //CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.8)
            //CGContextFillRect(ctx, txtRect)
            
            txtPath = CGPathCreateMutable()
            CGPathAddRect(txtPath, nil, txtRect)
            
            
            // draw string
            framesetter = CTFramesetterCreateWithAttributedString(cell)
            frame = CTFramesetterCreateFrame(framesetter, emptyRange, txtPath, nil)
            CTFrameDraw(frame, ctx);
        }
        
        /*
        
        
        // build string
        textString = CFStringCreateWithCString(nil, str.cStringUsingEncoding(NSASCIIStringEncoding), kCFStringEncodingASCII)
        attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        CFAttributedStringReplaceString (attrString, emptyRange, textString);
        
        // set attributes
        CFAttributedStringSetAttribute(attrString, strLenRange, kCTForegroundColorAttributeName, color);
        CFAttributedStringSetAttribute(attrString, strLenRange, kCTFontAttributeName, lFont)
        
        */
        
    }
    /*
    // calculate cellsHeight by getting max-height of cells
    private func calcCellsHeight(){
        // optimized for instruction-level parallelism
        var max1 : CGFloat = 0.0
        var max2 : CGFloat = 0.0
        var max3 : CGFloat = 0.0
        var max4 : CGFloat = 0.0
        
        var v1 : CGFloat = 0.0
        var v2 : CGFloat = 0.0
        var v3 : CGFloat = 0.0
        var v4 : CGFloat = 0.0
        
        var cellsCount = cells.count
        var i = 0;
        
        for (i = 0; i < cellsCount; i += 4) {
            v1 = CTFontGetSize(cells[i].cfString.)
            max1 =
        }
        max1 = max1 > max2 ? max1 : max2
        max3 = max3 > max4 ? max3 : max4
        max1 = max1 > max3 ? max1 : max3
        
        for (i = i - 4; i < cellsCount; i++){
            v1 = cells[i]
            if(max1 < v1){
                max1 = v1
            }
        }
        drawer.cellsHeight = CTFontGetSize(font)
    }
    */
    private func drawText(){
        
        let ctx : CGContextRef = NSGraphicsContext.currentContext()!.CGContext
        
        let txtRect : NSRect = NSRect(x: txtPaddingLeft, y: 0.0, width: 100000, height: height - cellsHeight)
        assert(txtRect.origin.x < width)
        assert(txtRect.origin.y + txtRect.height < height)
        
        let txtPath = CGPathCreateMutable()
        CGPathAddRect(txtPath, nil, txtRect)
        
        
        //CGContextSetRGBFillColor(ctx, 0.8, 0.8, 0, 0.2)
        //CGContextFillRect(ctx, txtRect)
        
        // draw string
        // Create the framesetter with the attributed string.
        let framesetter = CTFramesetterCreateWithAttributedString(text);
        //NSLog("\(text)")
        
        // Create a frame.
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), txtPath, nil)
        
        // Draw the specified frame in the given context.
        CTFrameDraw(frame, ctx);
        
    }
    
    
    // MARK: delegate-sending
    
    
    private func delegateWillRedraw() -> Bool {
        // informs delegate
        // delegate decides, if redrawing should proceed
        if(delegate == nil){
            return true
        }
        return self.delegate!.willRedraw(self)
    }
    
    private func delegateWillDraw() {
        // informs delegate
        delegate?.willDraw?(self)
        return
    }
    
    private func delegateDidDraw(){
        // informs delegate
        delegate?.didDraw?(self)
    }

}