// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore

/// Test the URLQueryItem resulting from various types of FieldsParameters
internal class FieldsParameterTests: XCTestCase {

    func testAll() {
        let sut = FieldValues([.all])
        let item = sut.queryItem
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "fields")
        XCTAssertEqual(item?.value, "all")
    }
    
    func testSome() {
        let sut = FieldValues([FieldType("foo"), FieldType("fields.bar")])
        let item = sut.queryItem
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "fields")
        XCTAssertEqual(item?.value, "foo,fields.bar")
    }
    
    func testNone() {
        let sut = FieldValues([.none])
        let item = sut.queryItem
        XCTAssertNil(item)
    }
    
    func testEmpty() {
        let emptyStringArray: [FieldType] = []
        let sut = FieldValues(emptyStringArray)
        let item = sut.queryItem
        XCTAssertNil(item)
    }

}
