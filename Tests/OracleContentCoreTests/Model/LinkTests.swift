// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore

class LinkTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
       
    }
    
    func testParse_WithTemplated() throws {
        
        let json = """
        {
            "href": "http://www.foo.com:2112/content/management/api/v1.1/items/CORE0633D21DEA97490593D6DE4E35FE8495/tags",
            "rel": "self",
            "method": "GET",
            "mediaType": "application/json",
            "templated": true
        }
        """
        
        let link = try LibraryJSONDecoder().decode(Link.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(link.href, "http://www.foo.com:2112/content/management/api/v1.1/items/CORE0633D21DEA97490593D6DE4E35FE8495/tags")
        XCTAssertEqual(link.rel, "self")
        XCTAssertEqual(link.method, "GET")
        XCTAssertEqual(link.mediaType, "application/json")
        XCTAssertNotNil(link.url)
        XCTAssertTrue(link.templated)
    }

    func testParse_MissingTemplated() throws {
        
        let json = """
        {
            "href": "http://www.foo.com:2112/content/management/api/v1.1/items/CORE0633D21DEA97490593D6DE4E35FE8495/tags",
            "rel": "self",
            "method": "GET",
            "mediaType": "application/json"
        }
        """
        
        let link = try LibraryJSONDecoder().decode(Link.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(link.href, "http://www.foo.com:2112/content/management/api/v1.1/items/CORE0633D21DEA97490593D6DE4E35FE8495/tags")
        XCTAssertEqual(link.rel, "self")
        XCTAssertEqual(link.method, "GET")
        XCTAssertEqual(link.mediaType, "application/json")
        XCTAssertNotNil(link.url)
        XCTAssertFalse(link.templated)
    }
    
}
