//
//  FSIconOptimizer.swift
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa


/*
    concept:
    loop over bars array, drawing the low indexes at the bottom, high indexes at the top

*/

public class FSIconDrawer: NSObject, IconDrawer {
    public private(set) var icon = NSImage()

    /// drawn histogramm data
    public var bars: [[FSIconBar]] = []

    /// first text line is subdivided in cells.count cells
    /// and filled with the content of the corresponding cell
    public var cells: [CFAttributedString] = []

    /// the text displayed bellow the cells
    public var text: CFAttributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)

    public var width: CGFloat = 128.0 {
        didSet {
            updateImgSize()
        }
    }
    public var height: CGFloat = 128.0 {
        didSet {
            updateImgSize()
        }
    }

    public var cellsHeight: CGFloat = 11.0

    public var txtPaddingLeft: CGFloat = 1.0
    public var txtPaddingRight: CGFloat = 1.0
    public var txtPaddingInbetween: CGFloat = 1.0

    public var delegate: IconDrawerDelegate?

    // MARK: init

    override public init () {
        super.init()
        updateImgSize()
        // this guy calls us to draw the image
        let myRep = NSCustomImageRep(drawSelector:Selector("drawIcon:"), delegate: self)
        icon.addRepresentation(myRep)
    }

    // MARK: drawIcon
    private func updateImgSize() {
        icon.size = NSSize(width: width, height: height)
    }
    public func drawIcon(anNSCustomImageRep: AnyObject) {
        // expects to be executed in a valid NSGraphicsContext

        let lWidth: CGFloat = width
        let lHeight: CGFloat = height

        delegateWillRedraw()

        if NSGraphicsContext.currentContext() == nil {
            NSLog("FSIconDrawer: no current NSGraphicContext")
            return
        }

        let ctx: CGContextRef = NSGraphicsContext.currentContext()!.CGContext

        // turn antialiasing off for energy save
        CGContextSetAllowsAntialiasing(ctx, false)
        CGContextSetShouldAntialias(ctx, false)

        // draw black background
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 1)
        CGContextFillRect(ctx, CGRectMake(0.0, 0.0, lWidth, lHeight))

        drawBars()
        drawText()
        drawCells()
    }

    private func drawBars() {
        /// lower horizontal edge y-coordinate
        var barBase: CGFloat = 0.0

        /// height of bar
        var barHeight: CGFloat = 0.0

        /// left vertical edge x-coordinate
        var barStart: CGFloat = 0.0

        /// horizontal width
        let barWidth: CGFloat = width / CGFloat(bars.count)

        // coordinate system: (0,0) left bottom corner

        let ctx: CGContextRef = NSGraphicsContext.currentContext()!.CGContext

        CGContextSetLineWidth(ctx, 0.0)

        for x in 0..<bars.count {
            let bar: [FSIconBar] = bars[x]
            barBase = 0.0
            // leftStartPoint: calculated absolute for
            barStart = barWidth * CGFloat(x)
            for y in 0..<bar.count {
                let b: FSIconBar = bar[y]
                barHeight = b.height
                //CGContextSetFillColor(ctx, &b.color)
                CGContextSetRGBFillColor(ctx, b.color[0], b.color[1], b.color[2], 1)
                CGContextFillRect(ctx, CGRectMake(barStart, barBase, barWidth, barHeight))
                barBase = barBase + barHeight
            }
        }
        assert(barHeight <= height)
    }

    private func drawCells() {
        let cellCount = cells.count
        let cellWidth: CGFloat = (
                width
                - txtPaddingLeft
                - txtPaddingRight
                - txtPaddingInbetween * CGFloat(cellCount-1)
            ) / CGFloat(cellCount)
        let cellHeight = height
        var cell: CFAttributedString

        // optimization of start calculation:
        //   CGFloat(i)* cellWidth + txtPaddingInbetween*CGFloat(i) + txtPaddingLeft
        // = CGFloat(i)*(cellWidth + txtPaddingInbetween)           + txtPaddingLeft
        // a * CGFloat(i) + b
        let a = cellWidth + txtPaddingInbetween
        let b = txtPaddingLeft

        let ctx: CGContextRef = NSGraphicsContext.currentContext()!.CGContext

        var txtRect: NSRect = NSRect(x: 0.0, y: 0.0, width: cellWidth*4, height: cellHeight)
        let emptyRange = CFRangeMake(0, 0)

        for i in 0..<cellCount {
            cell = cells[i]

            // left-start of cell
            txtRect.origin.x = CGFloat(i)*a + b

            let txtPath: CGMutablePathRef = CGPathCreateMutable()
            CGPathAddRect(txtPath, nil, txtRect)


            // draw string
            let framesetter = CTFramesetterCreateWithAttributedString(cell)
            let frame: CTFrameRef = CTFramesetterCreateFrame(framesetter, emptyRange, txtPath, nil)
            CTFrameDraw(frame, ctx)
        }
    }
    private func drawText() {

        let ctx: CGContextRef = NSGraphicsContext.currentContext()!.CGContext

        // use a high widht, so that long texts don't break the line
        let txtRect: NSRect = NSRect(
            x: txtPaddingLeft,
            y: 0.0,
            width: 1000*width,
            height: height - cellsHeight)

        assert(txtRect.origin.x < width)
        assert(txtRect.origin.y + txtRect.height < height)

        let txtPath = CGPathCreateMutable()
        CGPathAddRect(txtPath, nil, txtRect)

        // draw string
        // Create the framesetter with the attributed string.
        let framesetter = CTFramesetterCreateWithAttributedString(text)

        // Create a frame.
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), txtPath, nil)

        // Draw the specified frame in the given context.
        CTFrameDraw(frame, ctx)

    }


    // MARK: delegate-sending

    private func delegateWillRedraw() -> Bool {
        // informs delegate
        // delegate decides, if redrawing should proceed
        if delegate == nil {
            return true
        }
        return self.delegate!.willRedraw(self)
    }

}
