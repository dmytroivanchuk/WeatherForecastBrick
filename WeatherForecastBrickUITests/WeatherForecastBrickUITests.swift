//
//  WeatherForecastBrickUITests.swift
//  WeatherForecastBrickUITests
//
//  Created by Dmytro Ivanchuk on 30.08.2022.
//

import XCTest
import SnapshotTesting

class WeatherForecastBrickUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // set the record parameter to true in assertSnapshot statements each time running the test to record appropriate snapshots
    func test_infoButtonPressedAndBrickImagePulled_shouldMatchSnapshots() throws {
        let app = XCUIApplication()
        app.launch()

        sleep(1)
        let initialViewScreenshot = app.screenshot().image
        assertSnapshot(matching: initialViewScreenshot, as: .image(precision: 0.99, scale: nil))
        app.buttons["INFO"].tap()
        
        let customAlertScreenshot = app.screenshot().image
        assertSnapshot(matching: customAlertScreenshot, as: .image(precision: 0.99, scale: nil))
        app.buttons["Hide"].tap()
        
        app.swipeDown()
        assertSnapshot(matching: initialViewScreenshot, as: .image(precision: 0.99, scale: nil))
        
        app.tap()
        assertSnapshot(matching: initialViewScreenshot, as: .image(precision: 0.99, scale: nil))
    }
    
    func test_infoButtonPressed_shouldPresentCustomAlert() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["INFO"].tap()
        
        
        XCTAssert(app.staticTexts["INFO"].exists)
        
        let customAlertMessage = "Brick is wet - raining\nBrick is dry - sunny\nBrick is hard to see - fog\nBrick with cracks - very hot\nBrick with snow - snow\nBrick is swinging- windy\nBrick is gone - No Internet"
        let predicate = NSPredicate(format: "label LIKE %@", customAlertMessage)
        let element = app.staticTexts.element(matching: predicate)
        XCTAssert(element.exists)
        
        XCTAssert(app.buttons["Hide"].exists)
        
        
        app.buttons["Hide"].tap()

        XCTAssert(!element.exists)
        XCTAssert(!app.buttons["Hide"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
