//
//  NSMergedTableView.swift
//  CPU Spy
//
//  Created by Felice Serena on 09.02.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

// source: http://www.mactech.com/articles/mactech/Vol.18/18.11/1811TableTechniques/index.html

public final class FSMergedTableView : NSTableView {

    override public func frameOfCellAtColumn(column: Int, row: Int) -> NSRect {

        let ds = (dataSource() as? FSMergedTableViewDataSource)

        let colspanN: Int? = ds?.tableView?(self, spanForTableColumn: tableColumns[column], row: row)

        if colspanN == nil {
            return super.frameOfCellAtColumn(column, row: row)
        }

        let colspan = colspanN!
        if colspan == 0 {
            return NSZeroRect
        }
        if colspan == 1 {
            return super.frameOfCellAtColumn(column, row: row)
        }
        var merged: NSRect = super.frameOfCellAtColumn(column, row: row)

        for i in (column + 1)..<(column + colspan) {
            let next = super.frameOfCellAtColumn(i, row: row)
            merged = NSUnionRect(merged, next)
        }
        return merged
    }

     override public func drawRow(row: Int, clipRect aClipRect: NSRect) {
        let dsN = dataSource() as? FSMergedTableViewDataSource

        var firstCol: Int = columnIndexesInRect(aClipRect).firstIndex
        let colspanN = dsN?.tableView?(self, spanForTableColumn: tableColumns[firstCol], row: row)

        if colspanN == nil {
            super.drawRow(row, clipRect: aClipRect)
            return
        }
        
        let ds = dsN!

        var newClipRect = aClipRect

        var colspan = colspanN!

        while colspan == 0 {
            firstCol -= 1
            newClipRect = NSUnionRect(newClipRect, self.frameOfCellAtColumn(firstCol, row: row))
            colspan = ds.tableView!(self, spanForTableColumn: tableColumns[firstCol], row: row)
        }
        return super.drawRow(row, clipRect: newClipRect)
    }

}
