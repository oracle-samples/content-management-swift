// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentTest
import OracleContentCore

class CustomAssertTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension CustomAssertTests {
    
    func testInvalidURL() throws {
        let error = OracleContentError.invalidURL("foo")
        try XCTAssertErrorTypeMatchesInvalidURL(error, "foo")
    }
    
    func testInvalidURLWithIncorrectText() throws {
        let error = OracleContentError.invalidURL("foo")
        XCTExpectFailure("Expecting incorrect text error")
        
        try XCTAssertErrorTypeMatchesInvalidURL(error, "bar")
    }
    
    func testIncorrectErrorType() throws {
        let error = OracleContentError.couldNotCreateService
        XCTExpectFailure("Expecting incorrect error type")
        
        try XCTAssertErrorTypeMatchesInvalidURL(error, "foo")
    }
    
    func testIncorrectErrorType_CustomMessage() throws {
        let error = OracleContentError.couldNotCreateService
        XCTExpectFailure("Expecting incorrect error type")
        
        try XCTAssertErrorTypeMatchesInvalidURL(error, "foo", "Bad error type")
    }
}
