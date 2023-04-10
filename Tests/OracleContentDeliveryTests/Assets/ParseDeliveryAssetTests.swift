// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class ParseDeliveryAssetTests: XCTestCase {

    var bundle: Bundle!
    
    override func setUpWithError() throws {
        self.bundle = DeliveryBundleHelper.bundle(for: type(of: self))
    }

    override func tearDownWithError() throws {
        
    }

    /// Ensure that a dummy object based on the current Swagger model example can be parsed without error
    func testParseFromSwaggerModel() throws {
        let data = assetJSONFromSwagger.data(using: .utf8)!
        let result = try LibraryJSONDecoder().decode(Asset.self, from: data)
        XCTAssertEqual(result.identifier, "string")
        XCTAssertFalse(result.renditions.items.isEmpty)
    }
    
    /// Esnure that a digital asset is parseable into a DeliveryAPI.Asset
    /// Validate fields
    func testDigitalAssetParsing() throws {
        
        guard let data = URLProtocolMock.dataFromFile("DeliveryDigitalAsset.json", in: bundle) else {
            XCTFail()
            return
        }
        
        let decoder = LibraryJSONDecoder()
        
        let asset = try decoder.decode(OracleContentDelivery.Asset.self, from: data)
        
        XCTAssertEqual(asset.identifier, "CONT056331360A754795A8E63DFCA682E6EF")
        XCTAssertEqual(asset.type, "Image" )
        XCTAssertEqual(asset.name, "Blog_6_Header_1440x540px.jpg" )
        XCTAssertEqual(asset.desc, "This is a test description")
        
        XCTAssertTrue(asset.isDigitalAsset)
        XCTAssertFalse(asset.isContentItem)
        
        XCTAssertEqual(asset.digitalAssetFields?.metadata.width, "1440")
        XCTAssertEqual(asset.digitalAssetFields?.metadata.height, "540")
        
        XCTAssertNil(asset.contentItemFields)
        
        XCTAssertEqual(asset.digitalAssetFields?.size, 528070)
        
        XCTAssertEqual(asset.digitalAssetFields?.native.links.count, 1 )
        XCTAssertEqual(asset.digitalAssetFields?.renditions.count, 4 )
        XCTAssertEqual(asset.digitalAssetFields?.mimeType, "image/jpeg")
        XCTAssertEqual(asset.digitalAssetFields?.version, "")
        XCTAssertEqual(asset.digitalAssetFields?.fileType, "jpeg")
        
    }
    
    /// Ensure that an asset with "expand = all" can be decoded without error
    func testDecodeDigitalAsset_ExpandAll() throws {
        guard let data = URLProtocolMock.dataFromFile("DeliveryAssetIdResponseExpandAll.json", in: bundle) else {
            XCTFail()
            return
        }
        let decoder = LibraryJSONDecoder()
        let asset = try decoder.decode(OracleContentDelivery.Asset.self, from: data)
        
        print(asset)
    }
    
    /// Ensure that an asset that expands nothing can be decoded without error
    func testDecodeDigitalAsset_ExpandNone() throws {
        guard let data = URLProtocolMock.dataFromFile("DeliveryAssetIdResponseExpandNone.json", in: bundle) else {
            XCTFail()
            return
        }
        let decoder = LibraryJSONDecoder()
        let asset = try decoder.decode(OracleContentDelivery.Asset.self, from: data)
        
        print(asset)
    }
}

extension ParseDeliveryAssetTests {
    
/// Swagger data model from <server>/content/management/api/v1.1/swagger-ui/index.html#/Items/createItem
/// LAST UPDATED:  5 AUG 2021
    var assetJSONFromSwagger: String {
        print("LAST UPDATED FROM SWAGGER: 5 AUG 2021")
        return """
        {
          "id": "string",
          "type": "string",
          "typeCategory": "string",
          "name": "string",
          "description": "string",
          "slug": "string",
          "language": "string",
          "translatable": true,
          "createdDate": {
                    "value": "2019-04-16T16:35:24.526Z",
                    "timezone": "UTC"
        },
          "updatedDate": {
                    "value": "2019-04-16T16:35:24.526Z",
                    "timezone": "UTC"
        },
          "fields": {
            "additionalProp1": {},
            "additionalProp2": {},
            "additionalProp3": {}
          },
          "itemVariations": [
            {
              "varType": "string",
              "slug": "string",
              "setId": "string",
              "isMaster": true,
              "isPublished": true,
              "sourceId": "string",
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
              "status": "string",
              "sourceVersion": 0,
              "type": "string",
              "lastModified": "2021-08-05T13:41:52.299Z",
              "id": "string",
              "name": "string",
              "value": "string"
            }
          ],
          "taxonomies": {
            "items": [
              {
                "id": "string",
                "name": "string",
                "shortName": "string",
                "categories": {
                  "items": [
                    {
                      "id": "string",
                      "name": "string",
                      "apiName": "string",
                      "nodes": [
                        {
                          "id": "string",
                          "name": "string",
                          "apiName": "string"
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
          },
          "renditions": {
            "items": [
              {
                "apiName": "string",
                "formats": [
                  {
                    "format": "string",
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
                "type": "string"
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
          },
          "mimeType": "string",
          "fileGroup": "string",
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

