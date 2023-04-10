// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import OracleContentCore
import OracleContentDelivery

class ParseTaxonomiesTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testParseListTaxonomiesFromSwagger() throws {
        let data = jsonFromSwagger.data(using: .utf8)!
        let result = try LibraryJSONDecoder().decode(Taxonomies.self, from: data)
        XCTAssertTrue(result.hasMore)
    }
}

extension ParseTaxonomiesTests {
    var jsonFromSwagger: String {
        print("LAST UPDATED FROM SWAGGER: 5 AUG 2021")
        return """
        {
            "hasMore": true,
            "offset": 0,
            "count": 0,
            "limit": 0,
            "totalResults": 0,
            "properties": {
                "additionalProp1": {},
                "additionalProp2": {},
                "additionalProp3": {}
            },
            "items": [],
            "aggregationResults": [
                {
                    "name": "string"
                }
            ],
            "links": [
                {
                    "href": "string",
                    "rel": "string",
                    "templated": true,
                    "method": "string",
                    "profile": "string",
                    "mediaType": "string"
                }
            ]
        }
        """
    }
}
