//
//  Music_Discovery_UITests.swift
//  Music Discovery UITests
//
//  Created by Andrew Gerst on 6/26/16.
//  Copyright © 2016 Andrew Gerst. All rights reserved.
//

import XCTest

class Music_Discovery_UITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func waitForElementToAppear(element: XCUIElement, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectationForPredicate(existsPredicate, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(30.0) { error -> Void in
            if error != nil {
                let message = "Failed to find \(element) after 5 seconds."
                self.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
            }
        }
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let app = XCUIApplication()
        let tablesQuery = app.tables
        waitForElementToAppear(tablesQuery.staticTexts["Baby Baby Baby Baby"])
        snapshot("01Screen")
        tablesQuery.staticTexts["Baby Baby Baby Baby"].tap()
        snapshot("02Screen")
        waitForElementToAppear(app.buttons["Close"])
        app.buttons["Close"].tap()
        waitForElementToAppear(tablesQuery.staticTexts["...Baby One More Time - Britney Spears"])
        snapshot("03Screen")
        tablesQuery.staticTexts["...Baby One More Time - Britney Spears"].tap()
        waitForElementToAppear(app.buttons["Pause"])
        app.buttons["Pause"].tap()
        snapshot("04Screen")
    }

}
