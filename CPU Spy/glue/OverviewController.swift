//
//  OverviewController.swift
//  CPU Spy
//
//  Created by Felice Serena on 09.02.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import Cocoa


class OverviewController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        // Register the controller in the app delegate
        let appDelegate = NSApp.delegate as? AppDelegate
        appDelegate?.overviewController = self
    }
}