// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public struct NoAsset: Codable, SupportsStringDescription {
    public func stringDescription() -> String {
        return "<unused>"
    }
}

import XCTest
import OracleContentCore
import OracleContentDelivery

class ParseTaxonomyTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testJSONFromSwagger() throws {
        let data = jsonFromSwagger.data(using: .utf8)!
        let result = try LibraryJSONDecoder().decode(Taxonomy.self, from: data)
        XCTAssertEqual(result.identifier, "string")
    }
  
}

extension ParseTaxonomyTests {
    var jsonFromSwagger: String {
        print("LAST UPDATED FROM SWAGGER: 5 AUG 2021")
        return """
        {
            "id": "string",
            "name": "string",
            "description": "string",
            "shortName": "string",
            "customProperties": {
                "additionalProp1": "string",
                "additionalProp2": "string",
                "additionalProp3": "string"
            },
            "createdDate": {
                "value": "2019-04-16T16:35:24.526Z",
                "timezone": "UTC",
                "description": "string"
            },
            "updatedDate": {
                "value": "2019-04-16T16:35:24.526Z",
                "timezone": "UTC",
                "description": "string"
            },
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
