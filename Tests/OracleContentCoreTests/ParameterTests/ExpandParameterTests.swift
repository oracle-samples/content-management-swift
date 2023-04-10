// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore

/// Test the URLQueryItem resulting from various types of ExpandParameters
internal class ExpandParameterTests: XCTestCase {

    func testAll() {
        let sut = ExpandValues(.all)
        let item = sut.queryItem
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "expand")
        XCTAssertEqual(item?.value, "all")
    }
    
    func testNone() {
        let sut = ExpandValues(.none)
        let item = sut.queryItem
        
        XCTAssertNil(item)
    }
    
    func testUserDefined() {
        let sut = ExpandValues(["fields.foo"])
        let item = sut.queryItem
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "expand")
        XCTAssertEqual(item?.value, "fields.foo")
    }
    
    func testField() {
        let sut = ExpandValues(["foo"])
        let item = sut.queryItem
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "expand")
        XCTAssertEqual(item?.value, "foo")
    }
    
    func testMulitple() {
        let sut = ExpandValues(["fields.foo", "bar"])
        let item = sut.queryItem
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "expand")
        XCTAssertEqual(item?.value, "fields.foo,bar")
    }
    
    func testEmpty() {
        let parameter: [String] = []
        let sut = ExpandValues(parameter)
        let item = sut.queryItem
        
        XCTAssertNil(item)
    }
}
