// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import OracleContentCore
import OracleContentTest
import OracleContentDelivery

final class ReadTaxonomyCategoryTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }
    
    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
}

extension ReadTaxonomyCategoryTests {
    
    func testSpecificChannelToken() {
        let sut = DeliveryAPI.readTaxonomyCategory(taxonomyId: "123", categoryId: "456").version(.v1_1).channelToken("123")
        
        let request = sut.request
        let components = sut.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies/123/categories/456")
        XCTAssertEqual(components?.query, "channelToken=123")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testDefaultChannelToken() throws {
        Onboarding.urlProvider?.deliveryChannelToken = { return "456" }
        let sut = DeliveryAPI.readTaxonomyCategory(taxonomyId: "123", categoryId: "456").version(.v1_1)
        
        let request = sut.request
        let components = sut.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies/123/categories/456")
        XCTAssertEqual(components?.query, "channelToken=456")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testNotWellFormed_taxonomyId() throws {
        let sut = DeliveryAPI.readTaxonomyCategory(taxonomyId: "", categoryId: "456")
        let result = try sut.fetch().waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "Taxonomy ID cannot be empty.")
    }
    
    func testNotWellFormed_categoryId() throws {
        let sut = DeliveryAPI.readTaxonomyCategory(taxonomyId: "123", categoryId: "")
        let result = try sut.fetch().waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "TaxonomyCategory ID cannot be empty.")
    }
}

// MARK: Parse test
extension ReadTaxonomyCategoryTests {
    func testJSONFromSwagger() throws {
        let data = jsonFromSwagger.data(using: .utf8)!
        let result = try LibraryJSONDecoder().decode(TaxonomyCategory.self, from: data)
        XCTAssertEqual(result.identifier, "string")
        XCTAssertEqual(result.position, 1)
        XCTAssertEqual(result.ancestors.count, 1)
        XCTAssertEqual(result.children.properties.count, 3)
        XCTAssertEqual(result.children.items.count, 1)
        XCTAssertEqual(result.children.aggregationResults.count, 1)
        XCTAssertEqual(result.children.pinned.count, 1)
    }
    
}

extension ReadTaxonomyCategoryTests {
    var jsonFromSwagger: String {
        print("LAST UPDATED FROM SWAGGER: 12 DEC 2022")
        return """
        {
          "id": "string",
          "name": "string",
          "description": "string",
          "apiName": "string",
          "position": 1,
          "parent": {
            "id": "string",
            "name": "string",
            "apiName": "string"
          },
          "ancestors": [
            {
              "id": "string",
              "name": "string",
              "apiName": "string"
            }
          ],
          "children": {
            "hasMore": true,
            "offset": 0,
            "count": 0,
            "limit": 0,
            "totalResults": 1,
            "scrollId": "string",
            "properties": {
              "additionalProp1": {},
              "additionalProp2": {},
              "additionalProp3": {}
            },
            "items": [
              {
                "id": "string",
                "name": "string",
                "description": "string",
                "apiName": "string",
                "position": 0,
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
            ],
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
            ],
            "pinned": [
              "string"
            ]
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
