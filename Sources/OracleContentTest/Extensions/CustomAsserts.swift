// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import XCTest
import OracleContentCore

/// Assertion validating that an optional error is of the type OracleContentError.invalidURL
/// Also validates the associated String value
public func XCTAssertErrorTypeMatchesInvalidURL(
    _ error: Error?,
    _ expectedText: String,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws {
    
    let foundError = try XCTUnwrap(error, "Error is nil", file: file, line: line)
    
    switch foundError {
    case OracleContentError.invalidURL(let errorText):
        XCTAssertEqual(errorText, expectedText, message(), file: file, line: line)
        
    default:
        let message = message().isEmpty ? "Error is not of type OracleContentError.invalidURL" : message()
        XCTFail(message, file: file, line: line)
    }
}

/// Assertion validating that two URLs are equal
public func XCTAssertURLEqual(
    _ left: URL?,
    _ right: URL?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws {
    switch (left, right) {
    case (.none, .none):
        break
        
    case (.none, .some), (.some, .none):
        XCTFail(message(), file: file, line: line)
        
    case let (.some(lval), .some(rval)):
        let lComp = URLComponents(url: lval, resolvingAgainstBaseURL: false)
        let rComp = URLComponents(url: rval, resolvingAgainstBaseURL: false)
        
        guard let lComp = lComp, let rComp = rComp else {
            XCTFail(message(), file: file, line: line)
            return
        }
        
        XCTAssertEqual(lComp.scheme, rComp.scheme, file: file, line: line)
        XCTAssertEqual(lComp.host, rComp.host, file: file, line: line)
        XCTAssertEqual(lComp.port, rComp.port, file: file, line: line)
        XCTAssertEqual(lComp.path, rComp.path, file: file, line: line)
        
        switch (lval.queryDictionary, rval.queryDictionary) {
        case (.none, .none):
            break
            
        case (.some, .none), (.none, .some):
            XCTFail("Query dictionaries are not equal. \(message())", file: file, line: line)
            
        case let (.some(lqd), .some(rqd)):
            XCTAssertEqual(lqd, rqd, message(), file: file, line: line)
        }
    }
}

