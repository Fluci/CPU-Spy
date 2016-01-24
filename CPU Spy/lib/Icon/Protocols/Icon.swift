//
//  Icon.swift
//  CPU Spy
//
//  Created by Felice Serena on 24.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa

public protocol Icon {
    var delegate : IconDelegate? { get set }
    
    var drawer : IconDrawer { get set }
}