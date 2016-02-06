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

        let rand1 = Double((arc4random_uniform(600) + 10))/100.0
        let rand2 = Double((arc4random_uniform(600) + 10))/100.0
        let rand3 = Double((arc4random_uniform(600) + 10))/100.0

        var window = XCUIApplication().windows["Window"]
        var intervalForeground = window.textFields["sampleIntervalForeground"]
        var intervalBackground = window.textFields["sampleIntervalBackground"]
        var intervalHidden     = window.textFields["sampleIntervalHidden"]

        var refreshForeground = window.checkBoxes["refreshForeground"]
        var refreshBackground = window.checkBoxes["refreshBackground"]
        var refreshHidden     = window.checkBoxes["refreshHidden"]

        intervalForeground.click()
        intervalForeground.typeText("\r\(rand1)")

        intervalBackground.click()
        intervalBackground.typeText("\r\(rand2)")

        intervalHidden.click()
        intervalHidden.typeText("\r\(rand3)\t")

        refreshForeground.click()
        refreshBackground.click()
        refreshHidden.click()

        let refreshForegroundSet = (refreshForeground.value as? Int)!
        let refreshBackgroundSet = (refreshBackground.value as? Int)!
        let refreshHiddenSet     = (refreshHidden.value as? Int)!

        // restart
        XCUIApplication().terminate()
        XCUIApplication().launch()

        window = XCUIApplication().windows["Window"]
        intervalForeground = window.textFields["sampleIntervalForeground"]
        intervalBackground = window.textFields["sampleIntervalBackground"]
        intervalHidden     = window.textFields["sampleIntervalHidden"]

        refreshForeground = window.checkBoxes["refreshForeground"]
        refreshBackground = window.checkBoxes["refreshBackground"]
        refreshHidden     = window.checkBoxes["refreshHidden"]

        XCTAssertEqual(rand1, Double((intervalForeground.value as? String)!))
        XCTAssertEqual(rand2, Double((intervalBackground.value as? String)!))
        XCTAssertEqual(rand3, Double((intervalHidden.value as? String)!))

        XCTAssertEqual(refreshForegroundSet, (refreshForeground.value as? Int)!)
        XCTAssertEqual(refreshBackgroundSet, (refreshBackground.value as? Int)!)
        XCTAssertEqual(refreshHiddenSet,     (refreshHidden.value as? Int)!)

    }

}
