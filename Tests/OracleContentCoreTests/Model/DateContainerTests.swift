// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore
//@testable import OracleContentManagement

class DateContainerTests: XCTestCase {

    func testParse() throws {
        
        let json = """
        {
            "value": "2019-03-25T17:01:10.814Z",
            "timezone": "UTC"
        }
        """
        
        let dateContainer = try LibraryJSONDecoder().decode(DateContainer.self,
                                                            from: json.data(using: .utf8)!)
        
        XCTAssertEqual(dateContainer.value, "2019-03-25T17:01:10.814Z")
        XCTAssertEqual(dateContainer.timezone, "UTC")
        XCTAssertNotNil(dateContainer.dateValue())
        XCTAssertEqual(dateContainer.dateValue()?.timeIntervalSince1970, 1553533270.814)
        
    }
    
    func testBadDate() throws {
        
        let json = """
        {
            "value": "2019",
            "timezone": "UTC"
        }
        """
        
        let dateContainer = try LibraryJSONDecoder().decode(DateContainer.self,
                                                            from: json.data(using: .utf8)!)
        
        XCTAssertEqual(dateContainer.value, "2019")
        XCTAssertEqual(dateContainer.timezone, "UTC")
        XCTAssertNil(dateContainer.dateValue())
    }
    
    /// Validates that the `Date` returned by the DateContainer matches the `Date` used as part of intialization
    /// Useful because the initializer converts the `Date` to a string and `.dateValue()` converts back to a `Date`
    func testCreateDateContainer() throws {
        
        let initialDateString = "2022-02-23T20:23:28.860Z"
        
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let initialDate = f.date(from: initialDateString)

        let dc = DateContainer(date: initialDate)
        let d = dc.dateValue()
    
        XCTAssertEqual(initialDate, d)
    }

}
