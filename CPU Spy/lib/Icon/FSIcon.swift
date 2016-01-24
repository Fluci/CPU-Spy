//
//  FSIcon.swift
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa

/**
    Implements general mechanisms an Icon class might find useful.
*/
public class FSIcon : Icon, IconDrawerDelegate {
    public var delegate : IconDelegate?
    
    public var drawer : IconDrawer {
        didSet{
            drawer.delegate = self
        }
    }
    
    // MARK: Methods
    init (aDrawer : IconDrawer = FSIconDrawer()) {
        drawer = aDrawer;
        drawer.delegate = self
    }
    
    // MARK: delegate-sending
    
    /// informs delegate
    ///
    /// delegate decides, if redrawing should proceed
    internal func delegateWillRedraw() -> Bool {

        if let answer = self.delegate?.willRedraw(self) {
            return answer;
        }
        
        return true;
    }

    // MARK: delegate-receiving
    
    public func willRedraw(sender: IconDrawer) -> Bool {
        return delegateWillRedraw()
    }
    
}