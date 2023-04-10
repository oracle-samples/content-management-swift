// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class AssetConvenienceMethodTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
       
    }
    
    enum ConvenienceMethodError: Error {
        case couldNotLoadDataFromFile
    }
}

// MARK: Digital Asset Fields
extension AssetConvenienceMethodTests {
    func testDigitalAssetCustomFieldAsString() throws {
        
        let expectedValue: String = "bar"
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])

        let foundValue: String = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsAsset() throws {
        guard let data = URLProtocolMock.dataFromFile("DeliveryDigitalAsset.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundAsset: Asset = try asset.customField("foo")
        XCTAssertEqual(foundAsset.identifier, "CONT056331360A754795A8E63DFCA682E6EF")
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertNoThrow(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
        
    }
    
    func testDigitalAssetCustomFieldAsBool() throws {
        let expectedValue = false
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: Bool = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsDate() throws {
        
        let strategy = Date.ParseStrategy(
            format: "\(year: .padded(4))\(month: .twoDigits)\(day: .twoDigits)",
            locale: Locale(identifier: "fr_FR"),
            timeZone: TimeZone(abbreviation: "UTC")!)

        let expectedValue = try Date("20220412", strategy: strategy)
        
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: Date = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsDouble() throws {
        let expectedValue: Double = 21.12
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: Double = try asset.customField("foo")
        XCTAssertTrue(abs(expectedValue - foundValue) < 0.00001 )
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertNoThrow(try asset.customField("foo") as Int )
        XCTAssertNoThrow(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsInt64() throws {
        let expectedValue: Int64 = 2112
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: Int64 = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertNoThrow(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsInt() throws {
        let expectedValue: Int = 2112
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: Int = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Bool )
        XCTAssertNoThrow(try asset.customField("foo") as Int64)
        XCTAssertNoThrow(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsUInt() throws {
        let expectedValue: UInt = 2112
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: UInt = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertNoThrow(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsAny() throws {
        let expectedValue: String = "2112"
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: Any = try asset.customField("foo")
        let unwrapped = try XCTUnwrap(foundValue as? String)
        XCTAssertEqual(unwrapped, expectedValue)

        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsObject() throws {
        guard let data = URLProtocolMock.dataFromFile("DeliveryDigitalAsset.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundObject: [String: JSONValue<Asset>] = try asset.customField("foo")
        
        // Just testing that keys are equal as a smoke test
        let assetAsDictKeys = Set(assetAsDict.map { $0.key })
        let foundObjectKeys = Set(foundObject.map { $0.key })
        XCTAssertEqual(assetAsDictKeys, foundObjectKeys)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertNoThrow(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
        
    }

}

// MARK: Digital Asset Fields Array
extension AssetConvenienceMethodTests {
    func testDigitalAssetCustomFieldAsArrayOfString() throws {
        
        let expectedValue: [String] = ["bar"]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: [String] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsArrayOfAsset() throws {
        guard let data = URLProtocolMock.dataFromFile("DeliveryDigitalAsset.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(digitalAssetFields: ["foo": [jsonValue]])
        
        let foundAssets: [Asset] = try asset.customField("foo")
        XCTAssertEqual(foundAssets.count, 1)
        
        let firstAsset = try XCTUnwrap(foundAssets.first)
        XCTAssertEqual(firstAsset.identifier, "CONT056331360A754795A8E63DFCA682E6EF")
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
        
    }
    
    func testDigitalAssetCustomFieldAsArrayOfBool() throws {
        let expectedValue: [Bool] = [false]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: [Bool] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsArrayOfDate() throws {
        
        let strategy = Date.ParseStrategy(
            format: "\(year: .padded(4))\(month: .twoDigits)\(day: .twoDigits)",
            locale: Locale(identifier: "fr_FR"),
            timeZone: TimeZone(abbreviation: "UTC")!)

        let expectedValue = try Date("20220412", strategy: strategy)
        
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": [jsonValue]])
        
        let foundValue: [Date] = try asset.customField("foo")
        XCTAssertEqual(foundValue, [expectedValue])
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsArrayOfDouble() throws {
        let expectedValue: [Double] = [21.12]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: [Double] = try asset.customField("foo")
        
        XCTAssertEqual(foundValue.count, 1)
        
        let firstExpectedValue = try XCTUnwrap(expectedValue.first)
        let firstFoundValue = try XCTUnwrap(foundValue.first)
        
        XCTAssertTrue(abs(firstExpectedValue - firstFoundValue) < 0.00001 )
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsArrayOfInt64() throws {
        let expectedValue: [Int64] = [2112]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: [Int64] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsArrayOfInt() throws {
        let expectedValue: [Int] = [2112]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: [Int] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsArrayOfUInt() throws {
        let expectedValue: [UInt] = [2112]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(digitalAssetFields: ["foo": jsonValue])
        
        let foundValue: [UInt] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testDigitalAssetCustomFieldAsArrayOfObject() throws {
        guard let data = URLProtocolMock.dataFromFile("DeliveryDigitalAsset.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(digitalAssetFields: ["foo": [jsonValue]])
        
        let foundObject: [[String: JSONValue<Asset>]] = try asset.customField("foo")
        
        // Just testing that keys are equal as a smoke test
        let assetAsDictKeys = Set(assetAsDict.map { $0.key })
        let foundObjectKeys = Set(try XCTUnwrap(foundObject.first?.map { $0.key }))
        XCTAssertEqual(assetAsDictKeys, foundObjectKeys)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
        
    }

}

// MARK: ContentItem fields
extension AssetConvenienceMethodTests {
    func testContentItemCustomFieldAsString() throws {
        
        let expectedValue: String = "bar"
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: String = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsAsset() throws {
        guard let data = URLProtocolMock.dataFromFile("singleContentItem.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundAsset: Asset = try asset.customField("foo")
        XCTAssertEqual(foundAsset.identifier, "COREF626EC6D55534DA08D5E644ED3F81DAB")
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertNoThrow(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
        
    }
    
    func testContentItemCustomFieldAsBool() throws {
        let expectedValue = false
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: Bool = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsDate() throws {
        
        let strategy = Date.ParseStrategy(
            format: "\(year: .padded(4))\(month: .twoDigits)\(day: .twoDigits)",
            locale: Locale(identifier: "fr_FR"),
            timeZone: TimeZone(abbreviation: "UTC")!)

        let expectedValue = try Date("20220412", strategy: strategy)
        
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: Date = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsDouble() throws {
        let expectedValue: Double = 21.12
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: Double = try asset.customField("foo")
        XCTAssertTrue(abs(expectedValue - foundValue) < 0.00001 )
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertNoThrow(try asset.customField("foo") as Int )
        XCTAssertNoThrow(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertNoThrow(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsInt64() throws {
        let expectedValue: Int64 = 2112
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: Int64 = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertNoThrow(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsInt() throws {
        let expectedValue: Int = 2112
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: Int = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertNoThrow(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertNoThrow(try asset.customField("foo") as Int64)
        XCTAssertNoThrow(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsUInt() throws {
        let expectedValue: UInt = 2112
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: UInt = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertNoThrow(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsAny() throws {
        let expectedValue: String = "2112"
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: Any = try asset.customField("foo")
        let unwrapped = try XCTUnwrap(foundValue as? String)
        XCTAssertEqual(unwrapped, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsObject() throws {
        guard let data = URLProtocolMock.dataFromFile("singleContentItem.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundObject: [String: JSONValue<Asset>] = try asset.customField("foo")
        
        // Just testing that keys are equal as a smoke test
        let assetAsDictKeys = Set(assetAsDict.map { $0.key })
        let foundObjectKeys = Set(foundObject.map { $0.key })
        XCTAssertEqual(assetAsDictKeys, foundObjectKeys)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertNoThrow(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
        
    }
}

// MARK: ContentItem fields array
extension AssetConvenienceMethodTests {
    func testContentItemCustomFieldAsArrayOfString() throws {
        
        let expectedValue: [String] = ["bar"]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: [String] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsArrayOfAsset() throws {
        guard let data = URLProtocolMock.dataFromFile("singleContentItem.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(contentItemFields: ["foo": [jsonValue]])
        
        let foundValue: [Asset] = try asset.customField("foo")
        XCTAssertEqual(foundValue.count, 1)
        
        let firstFoundValue = try XCTUnwrap(foundValue.first)
        XCTAssertEqual(firstFoundValue.identifier, "COREF626EC6D55534DA08D5E644ED3F81DAB")
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
        
    }
    
    func testContentItemCustomFieldAsArrayOfBool() throws {
        let expectedValue: [Bool] = [false]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: [Bool] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsArrayOfDate() throws {
        
        let strategy = Date.ParseStrategy(
            format: "\(year: .padded(4))\(month: .twoDigits)\(day: .twoDigits)",
            locale: Locale(identifier: "fr_FR"),
            timeZone: TimeZone(abbreviation: "UTC")!)

        let expectedValue = try Date("20220412", strategy: strategy)
        
        let jsonValue = JSONValue<Asset>(any: [expectedValue])
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: [Date] = try asset.customField("foo")
        
        XCTAssertEqual(foundValue.count, 1)
        let firstFoundValue = try XCTUnwrap(foundValue.first)
        XCTAssertEqual(firstFoundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsArrayOfDouble() throws {
        let expectedValue: [Double] = [21.12]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: [Double] = try asset.customField("foo")
        
        XCTAssertEqual(foundValue.count, expectedValue.count)
        
        let firstFoundValue = try XCTUnwrap(foundValue.first)
        let firstExpectedValue = try XCTUnwrap(expectedValue.first)
        
        XCTAssertTrue(abs(firstExpectedValue - firstFoundValue) < 0.00001 )
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsArrayOfInt64() throws {
        let expectedValue: [Int64] = [2112]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: [Int64] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsArrayOfInt() throws {
        let expectedValue: [Int] = [2112]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: [Int] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsArrayOfUInt() throws {
        let expectedValue: [UInt] = [2112]
        let jsonValue = JSONValue<Asset>(any: expectedValue)
        
        let asset = Asset(contentItemFields: ["foo": jsonValue])
        
        let foundValue: [UInt] = try asset.customField("foo")
        XCTAssertEqual(foundValue, expectedValue)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
    
    func testContentItemCustomFieldAsArrayOfObject() throws {
        guard let data = URLProtocolMock.dataFromFile("singleContentItem.json", in: DeliveryBundleHelper.bundle(for: type(of: self))) else {
            throw ConvenienceMethodError.couldNotLoadDataFromFile
        }
        
        let assetAsDict = try LibraryJSONDecoder().decode([String: JSONValue<Asset>].self, from: data)
        let jsonValue = JSONValue<Asset>(any: assetAsDict)
        
        let asset = Asset(contentItemFields: ["foo": [jsonValue]])
        
        let foundObject: [[String: JSONValue<Asset>]] = try asset.customField("foo")
        
        // Just testing that keys are equal as a smoke test
        let assetAsDictKeys = Set(assetAsDict.map { $0.key })
        let foundObjectKeys = Set(try XCTUnwrap(foundObject.first?.map { $0.key }))
        XCTAssertEqual(assetAsDictKeys, foundObjectKeys)
        
        XCTAssertThrowsError(try asset.customField("foo") as String)
        XCTAssertThrowsError(try asset.customField("foo") as Asset)
        XCTAssertThrowsError(try asset.customField("foo") as Int )
        XCTAssertThrowsError(try asset.customField("foo") as UInt )
        XCTAssertThrowsError(try asset.customField("foo") as Bool)
        XCTAssertThrowsError(try asset.customField("foo") as Int64)
        XCTAssertThrowsError(try asset.customField("foo") as Double)
        XCTAssertThrowsError(try asset.customField("foo") as [String: JSONValue<Asset>])
        XCTAssertThrowsError(try asset.customField("foo") as Date)
        XCTAssertNoThrow(try asset.customField("foo") as Any)
    }
}

private extension Asset {
    convenience init(digitalAssetFields: [String: JSONValue<Asset>]) {
        self.init()
        
        let fields = EmbeddedDigitalAssetMetadata<Asset>()
        fields.customFields = digitalAssetFields
        self.fieldsEnum = .digitalAssetFields(fields)
    }
    
    convenience init(contentItemFields: [String: JSONValue<Asset>]) {
        self.init()
        
        self.fieldsEnum = .contentItemFields(contentItemFields)
    }
}
