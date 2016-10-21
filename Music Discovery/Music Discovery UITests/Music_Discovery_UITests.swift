import XCTest

class Music_Discovery_UITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
        XCUIDevice.shared().orientation = .portrait
    }

    override func tearDown() {
        super.tearDown()
    }

    fileprivate func waitForElementToAppear(_ element: XCUIElement, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 30.0) { error -> Void in
            if error != nil {
                let message = "Failed to find \(element) after 30 seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
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
