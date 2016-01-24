//
//  FSIconCell.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation


public struct FSIconCell {
    /// will be written in cell
    var string : String
    var cfString : CFAttributedString!
    /// color: r,g,b,a
    var color : CGColor = CGColorGetConstantColor(kCGColorWhite)!
    
    init(value: String){
        string = value;
    }
}