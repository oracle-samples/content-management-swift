// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore

internal class JSONValueTests: XCTestCase {
    
    @available(iOS 15.0, *)
    func testDate() {
        let d = Date()
        let sut = JSONValue<NoAsset>.date(d)
        XCTAssertEqual(sut.dateValue(), d)
        
    }
    func testBool() {
        let sut = JSONValue<NoAsset>(booleanLiteral: true)
        XCTAssertTrue(sut.boolValue() ?? false)
    }
    
    func testBool_AnyInitializer() {
        let sut = JSONValue<NoAsset>(any: true)
         XCTAssertTrue(sut.boolValue() ?? false)
    }
    
    func testString() {
        let sut = JSONValue<NoAsset>(stringLiteral: "testvalue")
        XCTAssertEqual(sut.stringValue(), "testvalue")
    }
    
    func testString_AnyInitializer() {
        let sut = JSONValue<NoAsset>(any: "testvalue")
        XCTAssertEqual(sut.stringValue(), "testvalue")
    }
    
    func testInt() {
        let sut = JSONValue<NoAsset>(integerLiteral: 2112)
        XCTAssertEqual(sut.intValue(), 2112)
    }
    
    func testInt_AnyInitializer() {
        let sut = JSONValue<NoAsset>(any: 2112)
        XCTAssertEqual(sut.intValue(), 2112)
    }
    
    func testDouble() {
        let sut = JSONValue<NoAsset>(floatLiteral: 21.12)
        XCTAssertEqual(sut.doubleValue(), 21.12)
    }
    
    func testDouble_AnyInitializer() {
        let sut = JSONValue<NoAsset>(any: 21.12)
        XCTAssertEqual(sut.doubleValue(), 21.12)
    }
    
    func testObject() throws {
  
        let sut = JSONValue<NoAsset>(
            dictionaryLiteral: ("key1", .string("foo")),
                               ("key2", .int(2112))
        )
        
        XCTAssertNotNil(sut.objectValue())
        XCTAssertEqual(sut.objectValue()?["key1"]?.stringValue(), "foo")
        XCTAssertEqual(sut.objectValue()?["key2"]?.intValue(), 2112)
    }
    
    func testObject_AnyInitializer() throws {
        
        let dict: [String: Any] = [
            "key1": "foo",
            "key2": 2112
        ]
        
        let sut = JSONValue<NoAsset>(any: dict)
        
        XCTAssertNotNil(sut.objectValue())
        XCTAssertEqual(sut.objectValue()?["key1"]?.stringValue(), "foo")
        XCTAssertEqual(sut.objectValue()?["key2"]?.intValue(), 2112)
      }
    
    func testArray() {
        let val1 = JSONValue<NoAsset>.int(1)
        let val2 = JSONValue<NoAsset>.int(2)
        let val3 = JSONValue<NoAsset>.string("foo")
        
        let sut = JSONValue<NoAsset>(arrayLiteral: val1, val2, val3)
       
        guard let assetArray = sut.arrayValue() else {
            XCTFail("Could not obtain array")
            return
        }
        
        // positive tests
        XCTAssertEqual(assetArray.count, 3)
        XCTAssertEqual(assetArray[0].intValue(), 1)
        XCTAssertEqual(assetArray[1].intValue(), 2)
        XCTAssertEqual(assetArray[2].stringValue(), "foo")
        
        // negative tests
        XCTAssertNil(sut.assetValue())
        XCTAssertNil(sut.boolValue())
        XCTAssertNil(sut.intValue())
        XCTAssertNil(sut.objectValue())
        XCTAssertNil(sut.doubleValue())
        XCTAssertNil(sut.dateValue())
    }
    
    func testArray_AnyInitializer() {
        let val1 = JSONValue<NoAsset>.int(1)
        let val2 = JSONValue<NoAsset>.int(2)
        let val3 = JSONValue<NoAsset>.string("foo")
        
        let sut = JSONValue<NoAsset>(any: [val1, val2, val3])
       
        guard let assetArray = sut.arrayValue() else {
            XCTFail("Could not obtain array")
            return
        }
        
        // positive tests
        XCTAssertEqual(assetArray.count, 3)
        XCTAssertEqual(assetArray[0].intValue(), 1)
        XCTAssertEqual(assetArray[1].intValue(), 2)
        XCTAssertEqual(assetArray[2].stringValue(), "foo")
        
        // negative tests
        XCTAssertNil(sut.assetValue())
        XCTAssertNil(sut.boolValue())
        XCTAssertNil(sut.intValue())
        XCTAssertNil(sut.objectValue())
        XCTAssertNil(sut.doubleValue())
        XCTAssertNil(sut.dateValue())
    }
    
    func testNull() {
        let sut = JSONValue<NoAsset>.null
        XCTAssertNil(sut.arrayValue())
        XCTAssertNil(sut.assetValue())
        XCTAssertNil(sut.boolValue())
        XCTAssertNil(sut.intValue())
        XCTAssertNil(sut.objectValue())
        XCTAssertNil(sut.doubleValue())
        XCTAssertNil(sut.value())
        XCTAssertNil(sut.dateValue())
    }
    
    func testDifferentDateTypes () throws {
        let data = JSONValueTests.jsonDates.data(using: .utf8)!
        let obj = try LibraryJSONDecoder().decode(DateStruct.self, from: data)
        let e = try LibraryJSONEncoder().encode(obj)
        let newObj = try LibraryJSONDecoder().decode(DateStruct.self, from: e)
        
        XCTAssertEqual(obj.foo.docsDate, newObj.foo.docsDate)
        XCTAssertEqual(obj.foo.containerDate, newObj.foo.containerDate)
        XCTAssertEqual(obj.foo.timestampDate, newObj.foo.timestampDate)
    }
    
    func testNumericValues() throws {
        
        let data = JSONValueTests.jsonNumerics.data(using: .utf8)!
        let obj = try LibraryJSONDecoder().decode([String: JSONValue<NoAsset>].self, from: data)
        XCTAssertEqual(obj["decimalZeroValue"]?.doubleValue(), 123.0)
        XCTAssertEqual(obj["decimalZeroValue"]?.intValue(), 123)
        XCTAssertEqual(obj["decimalZeroValue"]?.uint(), UInt(123))
        XCTAssertEqual(obj["decimalZeroValue"]?.int64Value(), Int64(123))
        
        XCTAssertEqual(obj["decimalValue"]?.doubleValue(), 123.12)
        XCTAssertEqual(obj["decimalValue"]?.intValue(), 123)
        XCTAssertEqual(obj["decimalValue"]?.uint(), UInt(123))
        XCTAssertEqual(obj["decimalValue"]?.int64Value(), Int64(123))
        
        // Precision becomes problematic when lengthy decimal places are present
        XCTAssertEqual(obj["doubleLengthyDecimalValue"]?.doubleValue(), 123.12345678912341)
        XCTAssertEqual(obj["doubleLengthyDecimalValue"]?.intValue(), 123)
        XCTAssertEqual(obj["doubleLengthyDecimalValue"]?.uint(), UInt(123))
        XCTAssertEqual(obj["doubleLengthyDecimalValue"]?.int64Value(), Int64(123))
        
    }

}

// MARK: Test different date types 
extension JSONValueTests {
    
    class DateStruct: NSObject, Codable, SupportsEmptyInitializer {
        @DecodableDefault.EmptyInit var foo: FooStruct
        
        required override init() { }
    }
    
    class FooStruct: NSObject, Codable, SupportsEmptyInitializer {
        @DecodableDefault.DistantPastDate var containerDate
        @DecodableDefault.DistantPastDate var timestampDate
        @DecodableDefault.DistantPastDate var docsDate
        
        required override init() { }
    }
    
    static let jsonDates = """
    {
        "foo": {
            "containerDate": {
                "value": "2020-06-18T13:50:16.101Z",
                "timezone": "UTC"
            },
            "timestampDate": 1641812204080,
            "docsDate": "2022-01-10T10:53:39Z"
        }
        
    }

    """
    
}

extension JSONValueTests {
    
    class NumberClass: NSObject, Codable, SupportsEmptyInitializer {
        @DecodableDefault.DoubleZero var doubleZeroValue
        @DecodableDefault.DoubleZero var doubleValue
        @DecodableDefault.DoubleZero var doubleLengthyDecimalValue
        @DecodableDefault.IntZero var integerValue
        @DecodableDefault.UIntZero var unitValue
        @DecodableDefault.Int64Zero var int64Value
        
        required override init() { }
    }
    
    static let jsonNumerics = """
    {
        "decimalZeroValue": 123.0,
        "decimalValue": 123.12,
        "doubleLengthyDecimalValue": 123.123456789123456789,
        "integerValue": 123,
        "uintValue": 123,
        "int64Value": 123
    }
    
    """
}
