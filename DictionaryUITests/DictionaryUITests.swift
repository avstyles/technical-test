//
//  Created by Andrew Styles on 20/03/2024.
//

import XCTest

final class DictionaryUITests: XCTestCase {

    func testDictionaryView_hasExpectedElements() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Dictionary"].exists)
        XCTAssertTrue(app.buttons["Submit"].exists)
        XCTAssertTrue(app.textFields["Enter any word"].exists)

    }
    
    func testDictionaryView_submitButtonEnablesWhenValueEntered() throws {
        let app = XCUIApplication()
        app.launch()
         
        let submitButton = app.buttons["Submit"]
        let textField = app.textFields["Enter any word"]
                            
        XCTAssertFalse(submitButton.isEnabled)
        textField.tap()
        textField.typeText("test")
        XCTAssertTrue(submitButton.isEnabled)
    }
    
    func testDictionaryView_submitWord_showsExpectedResponse() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UI_Testing")
        app.launchEnvironment["https://api.dictionaryapi.dev/api/v2/entries/en/test"] = JSONResponses.testJSONResponse
        app.launch()
        
         
        let submitButton = app.buttons["Submit"]
        let textField = app.textFields["Enter any word"]
                            
        XCTAssertFalse(submitButton.isEnabled)
        textField.tap()
        textField.typeText("test")
        XCTAssertTrue(submitButton.isEnabled)
        submitButton.tap()
        
        XCTAssertTrue(app.staticTexts["test"].exists)
        XCTAssertTrue(app.staticTexts["noun"].exists)
        
        XCTAssertTrue(app.staticTexts["1."].exists)
        XCTAssertTrue(app.staticTexts["A challenge, trial."].exists)

        XCTAssertTrue(app.staticTexts["2."].exists)
        XCTAssertTrue(app.staticTexts["A cupel or cupelling hearth in which precious metals are melted for trial and refinement."].exists)

        XCTAssertTrue(app.staticTexts["3."].exists)
        XCTAssertTrue(app.staticTexts["(academia) An examination, given often during the academic term."].exists)
    }
}
