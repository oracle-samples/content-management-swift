// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore

/// Test the URLQueryItem resulting from various types of LinksParameters
internal class LinksParameterTests: XCTestCase {

    func testSelf() {
        let sut = ReadLinksValues([.selfLink])
        let item = sut.queryItem
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "links")
        XCTAssertEqual(item?.value, "self")
        
    }
    
    func testDescribedBy() {
        let sut = ReadLinksValues([.describedBy])
        let item = sut.queryItem
          
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "links")
        XCTAssertEqual(item?.value, "describedBy")
    }
    
    func testCanonical() {
        let sut = ReadLinksValues([.canonical])
        let item = sut.queryItem
          
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "links")
        XCTAssertEqual(item?.value, "canonical")
    }
    
    func testSome() {
        let sut = ReadLinksValues([.selfLink, .describedBy, .canonical])
        let item = sut.queryItem
          
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "links")
        XCTAssertEqual(item?.value, "self,describedBy,canonical")
    }
    
    func testNone() {
        let sut = ReadLinksValues([])
        let item = sut.queryItem
          
        XCTAssertNil(item)
    }

}
