//
//  footStepMeterUITests.swift
//  footStepMeterUITests
//
//  Created by Takahiro Kato on 2017/05/21.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import XCTest

class FootStepMeterUITests: XCTestCase {
        
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
    
    func testCancelStart() {
        let app = XCUIApplication()
        app.tabBars.buttons["START"].tap()
        app.toolbars.buttons["Cancel"].tap()
    }
    
    func testCancelInputTitle() {
        let app = XCUIApplication()
        app.tabBars.buttons["START"].tap()
        app.toolbars.buttons["Done"].tap()
        app.alerts["Confirm"].buttons["Cancel"].tap()
    }
    
    func testTapFootViewTabBarItem() {
        let app = XCUIApplication()
        app.tabBars.buttons["Foot View"].tap()
        app.alerts["Alert"].buttons["OK"].tap()
    }
    
    func testTransitionScreen() {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        app.tables.staticTexts["About App"].tap()
        app.navigationBars["About App"].buttons["Back"].tap()
        app.navigationBars["Settings"].buttons["Back"].tap()
    }
}
