// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import XCTest
import OracleContentCore

/// This test assertion passes if the query of the given URL contains the specified key, value combination
/// - parameter URL: The URL to validate
/// - parameter key: The key of the query component for which to look
/// - parameter value: The value of the key
public func XCTAssertURLContainsQueryKeyAndValue(
    _ url: URL,
    _ key: String,
    _ value: String,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws {
    
    let query = try XCTUnwrap(url.query, "URL did not contain a query", file: file, line: line)
    let result = try XCTUnwrap(dictionary(from: query), "URL query does not contain any key, value pairs", file: file, line: line)
    let keyValue = try XCTUnwrap(result[key], "URL query does not contain key \"\(key)\"", file: file, line: line)
    XCTAssertEqual(value, keyValue, message(), file: file, line: line )
}

