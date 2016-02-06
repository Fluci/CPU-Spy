//
//  Tokenizer.swift
//  CPU Spy
//
//  Created by Felice Serena on 06.02.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


protocol Tokenizer {
    var psOutput: FSString { get set }
    var activeLine: FSString { get }

    var headerStr: FSString { get }
    var header: [FSString] { get }

    func readHeader() throws -> [FSString]

    func hasNext() -> Bool

    func readNextRow() throws -> [FSString]!
}
