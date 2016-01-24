//
//  FSIconCell.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

public struct FSIconCell {
    var string : String // will be written in cell
    var cfString : CFAttributedString!
    var color : CGColor = CGColorGetConstantColor(kCGColorWhite)! // color: r,g,b,a
    
    init(value: String){
        string = value;
    }
}