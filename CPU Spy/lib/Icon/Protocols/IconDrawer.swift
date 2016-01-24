//
//  IconDrawer.swift
//  CPU Spy
//
//  Created by Felice Serena on 24.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

public protocol IconDrawer {
    var icon : NSImage { get };

    /// drawn histogramm data
    var bars : [[FSIconBar]] { get set }
    
    /// first text line is subdivided in cells.count cells and filled with the content of the corresponding cell
    var cells : [CFAttributedString] { get set }
    
    /// the text displayed bellow the cells
    var text : CFAttributedString { get set }
    
    var width  : CGFloat { get set }
    var height : CGFloat { get set }
    
    var cellsHeight : CGFloat { get set }
    
    var txtPaddingLeft : CGFloat { get set }
    var txtPaddingRight : CGFloat { get set }
    var txtPaddingInbetween : CGFloat { get set }
    
    var delegate : IconDrawerDelegate? { get set }
}