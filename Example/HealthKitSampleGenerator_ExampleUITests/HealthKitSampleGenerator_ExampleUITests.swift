//
//  HealthKitSampleGenerator_ExampleUITests.swift
//  HealthKitSampleGenerator_ExampleUITests
//
//  Created by Michael Seemann on 07.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest

class HealthKitSampleGenerator_ExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        // set a random output string
        let specifyANameForTheProfileTextField = app.textFields["specify a name for the profile"]
        specifyANameForTheProfileTextField.tap()
        specifyANameForTheProfileTextField.typeText(NSUUID().UUIDString)
        app.typeText("\n")
        // create the export
        let exportButton = app.buttons["Export HealthKit Data"]
        exportButton.tap()
        
        // disable overwrite
        app.switches["1"].tap()
        
        //export button should be disabled
        XCTAssertEqual(exportButton.enabled, false)
    }

}
