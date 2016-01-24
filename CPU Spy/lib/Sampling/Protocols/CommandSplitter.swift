//
//  CommandSplitter.swift
//  CPU Spy
//
//  Created by Felice Serena on 23.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Foundation

protocol CommandSplitter {
    func split(command : FSString) -> (path : FSString?, exec : FSString, args : [FSString])
}