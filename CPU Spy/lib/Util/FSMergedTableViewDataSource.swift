//
//  FSMergedTableViewDataSource.swift
//  CPU Spy
//
//  Created by Felice Serena on 09.02.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa


@objc public protocol FSMergedTableViewDataSource: NSTableViewDataSource {
    optional func tableView(
        tableView: FSMergedTableView,
        spanForTableColumn tableColumn: NSTableColumn,
        row: Int
    ) -> Int
}
