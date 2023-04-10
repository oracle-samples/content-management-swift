// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore
import OracleContentTest

/// Perform validations of the helper methods on OracleContentError which can extract portions
/// of the associated values for a particular case
class OracleContentErrorTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
    
    }
}

extension OracleContentErrorTests {
    func testAssociatedString() throws {
        let sut = OracleContentError.invalidURL("foo")
        let s = try XCTUnwrap(sut.associatedString)
        XCTAssertEqual(s, "foo")
    }
    
    func testAssociatedString_Nil() throws {
        let sut = OracleContentError.couldNotCreateService
        XCTAssertNil(sut.associatedString)
    }
    
    func testAssociatedURL() throws {
        let url = URL(staticString: "http://www.foo.com")
        let sut = OracleContentError.couldNotCreateImageFromURL(url)
        let foundURL = try XCTUnwrap(sut.associatedURL)
        try XCTAssertURLEqual(url, foundURL)
    }
    
    func testAssociatedURL_Nil() throws {
        let sut = OracleContentError.couldNotCreateImageFromURL(nil)
        XCTAssertNil(sut.associatedURL)
    }
    
    func testAssociatedURL_Nil_DifferentErrorType() throws {
        let sut = OracleContentError.couldNotCreateService
        XCTAssertNil(sut.associatedURL)
    }
    
    func testAssociatedJSONValue() throws {
        let jsonValue: JSONValue<NoAsset> = 1
        let sut =  OracleContentError.responseStatusError(123, jsonValue)
        let result = try XCTUnwrap(sut.associatedJSONValue)
        XCTAssertEqual(result.jsonString(), jsonValue.jsonString())
    }
    
    func testAssociatedJSONValue_Nil() throws {
        let sut =  OracleContentError.couldNotCreateService
        XCTAssertNil(sut.associatedJSONValue)
    }
    
    func testAssociatedServerStatusCode() throws {
        let jsonValue: JSONValue<NoAsset> = 1
        let sut =  OracleContentError.responseStatusError(123, jsonValue)
        let result = try XCTUnwrap(sut.associatedServerStatusCode)
        XCTAssertEqual(result, 123)
    }
    
    func testAssociatedServerStatusCode_Nil() throws {
        let sut =  OracleContentError.couldNotCreateService
        XCTAssertNil(sut.associatedServerStatusCode)
    }
}
