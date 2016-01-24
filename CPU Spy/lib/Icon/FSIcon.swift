//
//  FSIcon.swift
//  CPU Spy
//
//  Created by Felice Serena on 14.6.15.
//  Copyright (c) 2015 Serena. All rights reserved.
//

import Cocoa

@objc public protocol FSIconDelegate : NSObjectProtocol {
    optional func willDraw(sender: NSObject)
    optional func didDraw(sender: NSObject)
    
    func willRedraw(sender: FSIcon) -> Bool
}


public class FSIcon : NSObject, FSIconDrawerDelegate {
    
    internal var isDirty = true
    
    public var font : CTFontRef = CTFontCreateWithName("Menlo Regular", 10.0, nil) {
        didSet{
            drawer.cellsHeight = CTFontGetSize(font)
            isDirty = true
        }
    }
    
    var icon : NSImage {
        get {
            return drawer.icon
        }
    }
    public var width : Double {
        set(newVal){
            drawer.width = CGFloat(newVal)
            isDirty = true
        }
        get{
            return Double(drawer.width)
        }
    }
    public var height : Double {
        set(newVal){
            drawer.height = CGFloat(newVal)
            isDirty = true
        }
        get{
            return Double(drawer.height)
        }
    }
    
    public var delegate : FSIconDelegate?
    
    public var drawer : FSIconDrawer = FSIconDrawer() {
        didSet{
            drawer.delegate = self
        }
    }
    
    // MARK: Methods
    override init () {
        super.init()
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
    
    internal func delegateWillDraw() {
        // informs delegate
        self.delegate?.willDraw?(self)
    }
    
    internal func delegateDidDraw(){
        // informs delegate
        self.delegate?.didDraw?(self)
    }
    
    // MARK: delegate-receiving
    public func didDraw(sender: FSIconDrawer) {
        return delegateDidDraw()
    }
    
    public func willDraw(sender: FSIconDrawer) {
        return delegateWillDraw()
    }
    
    public func willRedraw(sender: FSIconDrawer) -> Bool {
        return delegateWillRedraw()
    }
    
}