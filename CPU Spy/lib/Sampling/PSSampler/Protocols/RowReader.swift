//
//  RowReader.swift
//  CPU Spy
//
//  Created by Felice Serena on 06.02.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


protocol RowReader {

    init(aSplitter: CommandSplitter)

    var titleMap: [String : Int]! { get set }

    // MARK: read row to processSample

    var dateFormatter: NSDateFormatter { get }

    /// main entry: defines mapping between ps-cols and corresponding processorSample attributes
    func readRow(line: [FSString]) throws -> ProcessSample
}
