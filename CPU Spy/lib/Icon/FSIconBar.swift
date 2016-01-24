//
//  PSSampling_Datatypes.swift
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Foundation


public struct FSIconBar {
    var color : [CGFloat] = [1.0, 1.0, 1.0, 0.0] // color: r,g,b,a
    var height : CGFloat // height in CG-coordinate system (scaling not done by FSIconDrawer because of performance
    
    init(aHeight : CGFloat = 1.0) {
        height = aHeight
    }
}
