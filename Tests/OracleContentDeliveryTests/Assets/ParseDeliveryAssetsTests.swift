// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class ParseDeliveryAssetsTests: XCTestCase {

    var bundle: Bundle!
    
    override func setUpWithError() throws {
        self.bundle = DeliveryBundleHelper.bundle(for: type(of: self))
    }

    override func tearDownWithError() throws {
        
    }
    
    /// Ensure that a dummy object based on the current Swagger model example can be parsed without error
    func testParseFromSwaggerModel() throws {
        let data = listAssetsJSONFromSwagger.data(using: .utf8)!
        let result = try LibraryJSONDecoder().decode(Assets.self, from: data)
        XCTAssertTrue(result.hasMore)
    }
    
    /// Validate the top level values of a sample response
    func testSearchResponse_TopLevelValues() throws {
        guard let data = URLProtocolMock.dataFromFile(
            "DeliverySearchResponse.json",
             in: bundle
        ) else {
            XCTFail("Unable to load data")
            return
        }
        
        let decoder = LibraryJSONDecoder()
        let results = try decoder.decode(OracleContentDelivery.Assets.self, from: data)
        
        XCTAssertFalse(results.hasMore)
        XCTAssertEqual(results.offset, 0)
        XCTAssertEqual(results.count, 11)
        XCTAssertEqual(results.limit, 11)
        XCTAssertEqual(results.totalResults, 11)
        XCTAssertEqual(results.links.count, 5)
        XCTAssertEqual(results.items.count, 11)
        
    }
    
    /// Validate that the items returned correctly evaluate to "isContentItem" or "isDigitalAsset"
    func testSearchResponse_ItemValues() throws {
        guard let data = URLProtocolMock.dataFromFile(
            "DeliverySearchResponse.json",
            in: bundle
        ) else {
            XCTFail("Unable to load data")
            return
        }
        
        let decoder = LibraryJSONDecoder()
        let results = try decoder.decode(OracleContentDelivery.Assets.self, from: data)
        
        XCTAssertTrue(results.items[0].isContentItem)
        XCTAssertTrue(results.items[1].isContentItem)
        XCTAssertTrue(results.items[2].isContentItem)
        XCTAssertTrue(results.items[3].isContentItem)
        XCTAssertTrue(results.items[4].isContentItem)
        
        XCTAssertTrue(results.items[5].isDigitalAsset)
        XCTAssertTrue(results.items[6].isDigitalAsset)
        XCTAssertTrue(results.items[7].isDigitalAsset)
        XCTAssertTrue(results.items[8].isDigitalAsset)
        XCTAssertTrue(results.items[9].isDigitalAsset)
        XCTAssertTrue(results.items[10].isDigitalAsset)
    }
}

extension ParseDeliveryAssetsTests {
    /// Swagger data model from <server>/content/published/api/v1.1/swagger-ui/index.html#/Items/getItemsForDelivery
    /// LAST UPDATED:  5 AUG 2021
    var listAssetsJSONFromSwagger: String {
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
