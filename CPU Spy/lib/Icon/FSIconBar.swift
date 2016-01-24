//
//  PSSampling_Datatypes.swift
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation


public struct FSIconBar {
    /// color: r,g,b,a
    var color : [CGFloat] = [1.0, 1.0, 1.0, 0.0]
    
    /// height in CG-coordinate system (scaling not done by FSIconDrawer)
    var height : CGFloat
    
    init(aHeight : CGFloat = 1.0) {
        height = aHeight
    }
}
