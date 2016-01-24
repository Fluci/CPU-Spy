//
//  IconDrawer.swift
//  CPU Spy
//
//  Created by Felice Serena on 24.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

public protocol IconDelegate {
    func willRedraw(sender: Icon) -> Bool
}
