//
//  CPU_SpyUITests.swift
//  CPU SpyUITests
//
//  Created by Felice Serena on 22.01.16.
//  Copyright © 2016 Serena. All rights reserved.
//

import XCTest

class CPUSpyUITests: XCTestCase {
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before
        // the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        // Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the
        // initial state - such as interface orientation - required for your
        // tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after
        // the invocation of each test method in the class.

        super.tearDown()
    }

    func testDefaultIntervals() {
        let window = XCUIApplication().windows["Window"]

        let foreground = window.textFields["sampleIntervalForeground"]
        let background = window.textFields["sampleIntervalBackground"]
        let hidden = window.textFields["sampleIntervalHidden"]

        var field = foreground
        field.click()
        field.typeText("\r0\r")
        XCTAssertLessThan(0.0, Double((field.value as? String)!)!)
        field.typeText("\r-0.1\r")
        XCTAssertLessThan(0.0, Double((field.value as? String)!)!)

        field = background
        field.click()
        field.typeText("\r0\r")
        XCTAssertLessThan(0.0, Double((field.value as? String)!)!)
        field.typeText("\r-0.1\r")
        XCTAssertLessThan(0.0, Double((field.value as? String)!)!)

        field = hidden
        field.click()
        field.typeText("\r0\r")
        XCTAssertLessThan(0.0, Double((field.value as? String)!)!)
        field.typeText("\r-0.1\r")
        XCTAssertLessThan(0.0, Double((field.value as? String)!)!)
    }

    func testStoring() {
        // Use recording to get started writing UI tests.

        let rand1 = Double((arc4random_uniform(600) + 1))/100.0
        let rand2 = Double((arc4random_uniform(600) + 1))/100.0
        let rand3 = Double((arc4random_uniform(600) + 1))/100.0

        var window = XCUIApplication().windows["Window"]
        var foreground = window.textFields["sampleIntervalForeground"]
        var background = window.textFields["sampleIntervalBackground"]
        var hidden = window.textFields["sampleIntervalHidden"]

        foreground.click()
        foreground.typeText("\r\(rand1)")

        background.click()
        background.typeText("\r\(rand2)")

        hidden.click()
        hidden.typeText("\r\(rand3)\t")

        XCUIApplication().terminate()
        // restart
        XCUIApplication().launch()
        window = XCUIApplication().windows["Window"]
        foreground = window.textFields["sampleIntervalForeground"]
        background = window.textFields["sampleIntervalBackground"]
        hidden = window.textFields["sampleIntervalHidden"]

        XCTAssertEqual(rand1, Double((foreground.value as? String)!))
        XCTAssertEqual(rand2, Double((background.value as? String)!))
        XCTAssertEqual(rand3, Double((hidden.value as? String)!))
    }

}
