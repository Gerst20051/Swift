import XCTest

class Music_Discovery_UITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
        XCUIDevice.sharedDevice().orientation = .Portrait
    }

    override func tearDown() {
        super.tearDown()
    }

    private func waitForElementToAppear(element: XCUIElement, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectationForPredicate(existsPredicate, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(30.0) { error -> Void in
            if error != nil {
                let message = "Failed to find \(element) after 30 seconds."
                self.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
            }
        }
    }

    func testExample() {
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
