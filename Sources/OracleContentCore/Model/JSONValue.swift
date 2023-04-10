// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
// swiftlint:disable line_length
    
import Foundation

/// Errors thrown while attempting to convert JSONValue data to values of specific types
public enum JSONValueError: LocalizedError {
    case fieldNotFound(String)
    case couldNotParse(String, String)
    case unspecifiedFieldType(String)
    case incompleteAsset

    public var errorDescription: String? {
        switch self {
        case let .couldNotParse(field, type):
            return "Could not parse content item field \"\(field)\" as type \"\(type)\""
            
        case .unspecifiedFieldType(let field):
            return "Unable to parse field \"\(field)\" because the type could not be inferred"
            
        case let .fieldNotFound(field):
            return "Could not find field named \(field)"
            
        case .incompleteAsset:
            return "The asset is incomplete. Consider utilizing an expand parameter on the request that produced this asset or issue a new request to obtain the full asset details via a readAsset method."
        }
    }
}

/// Enumeration which allows for parsing of arbitrary JSON string data into an object that may be easily queried. A JSONValue object is generic over `ModelType` which must conform to both `Codable` and ``SupportsStringDescription`` - for example, `JSONValue<Asset>` or `JSONValue<NoAsset>`
///
/// JSON data is received as a dictionary of `[String: Any]` objects. This poses a big problem for anyone wishing to deal with arbitrary JSON that does not explicitly match a model object.
/// Callers are forced to write lots of conditional casting code.
///
/// JSONValue exists to help calling code by transforming JSON into an enumeration that callers may just "switch" over. See unit tests for examples.
public enum JSONValue<ModelType: Codable & SupportsStringDescription>: Codable {
    
    /// JSON value data is a String
    case string(String)
    
    /// JSON value data is an Int
    case int(Int)
    
    /// JSON value is Int64
    case int64(Int64)
    
    case uint(UInt)
    
    /// JSON value data is a Double
    case double(Double)
    
    /// JSON value data is a Bool
    case bool(Bool)
    
    /// JSONValue data is a Date
    case date(Date)
    
    /// JSONValue data is an object of type `ModelType`
    case object([String: JSONValue<ModelType>])
    
    /// JSONValue data is an array of type where each element is of type `ModelType`
    case array([JSONValue<ModelType>])
    
    /// JSONValue data is NULL
    case null
    
    /// Returns the value of the specified JSONValue
    /// - returns: String?
    public func stringValue() -> String? {
        switch self {
        case .string(let value):
            return value
        
        default:
            return nil
        }
    }
    
    /// Attempts to convert the associated value for a JSONValue into an AssetType
    /// In order to succeed, the JSONValue must be .object and the associated value
    /// must able to be tranformed into JSON and decoded into AssetType
    /// If anything goes wrong in that process, nil is returned
    /// - returns: ModelType?
    public func assetValue() -> ModelType? {
        switch self {
        case .object(let json):
            let encoder = LibraryJSONEncoder()
            
            // convert back to JSON
            guard let encodedJSON = try? encoder.encode(json) else {
                return nil
            }

            // attempt to decode that to AssetType
            let decoder = LibraryJSONDecoder()
            do {
                let asset = try decoder.decode(ModelType.self, from: encodedJSON)
                return asset
            } catch {
                Onboarding.logError(error.localizedDescription)
                return nil
            }

        default:
            return nil
        }
    }
    
    /// Convert a JSONValue to Double 
    public func doubleValue() -> Double? {
        switch self {
        case .double(let value):
            return value
            
        case .int(let value):
            return Double(value)
            
        case .int64(let value):
            return Double(value)
            
        case .uint(let value):
            return Double(value)
            
        default:
            return nil 
        }
    }
    
    /// Returns the value of the specified JSONValue
    /// - returns: Int?
    public func intValue() -> Int? {
        switch self {
        case .int(let value):
            return value
            
        case .double(let value):
            return Int(value)
            
        default:
            return nil
        }
    }
    
    /// Returns the value of the specified JSONValue
    /// - returns: Int64?
    public func int64Value() -> Int64? {
        switch self {
        case .int64(let value):
            return value
            
        case .int(let value):
            return Int64(value)
            
        case .double(let value):
            return Int64(value)

        default:
            return nil
        }
    }
    
    /// Returns the value of the specified JSONValue
    /// - returns: Int64?
    public func uint() -> UInt? {
        switch self {
        case .uint(let value):
            return value
            
        case .int(let value):
            return UInt(value)
            
        case .double(let value):
            return UInt(value)

        default:
            return nil
        }
    }
    
    /// Returns the value of the specified JSONValue
    /// - returns: [String: JSONValue<ModelType>]?
    public func objectValue() -> [String: JSONValue<ModelType>]? {
        switch self {
        case .object(let dict):
            return dict
            
        default:
            return nil
        }
    }
    
    /// Returns the value of the specified JSONValue
    /// - returns: [JSONValue<ModelType>]?
    public func arrayValue() -> [JSONValue<ModelType>]? {
        switch self {
        case .array(let value):
            return value
            
        default:
            return nil
        }
    }
    
    /// Returns the value of the specified JSONValue
    /// - returns: Bool?
    public func boolValue() -> Bool? {
        switch self {
        case .bool(let value):
            return value
            
        default:
            return nil
        }
    }
    
    public func dateValue() -> Date? {
        switch self {
        case .date(let dateContainer):
            return dateContainer
            
        default:
            return nil
        }
    }
    
    /// Returns the value of the specified JSONValue as an Any
    /// - returns: Any
    public func value() -> Any? {
        if case let .string(string) = self {
            return string
        }
        else if case let .int(int) = self {
            return int
        }
        else if case let .int64(int64) = self {
            return int64
        }
        else if case let .uint(uint) = self {
            return uint
        }
        else if case let .double(double) = self {
            return double
        }
        else if case let .bool(bool) = self {
            return bool
        }
        else if case let .date(containervalue) = self {
            return containervalue
        }
        else if case let .object(object) = self {
            return object.mapValues { $0.value() }
        }
        else if case let .array(array) = self {
            return array.map { $0.value() }
        }
        else if case .null = self {
            return nil
        }
        else {
            return value
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Int64.self) {
            self = .int64(value)
        } else if let value = try? container.decode(UInt.self) {
            self = .uint(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Date.self) {
            self = .date(value)
        } else if let value = try? container.decode([String: JSONValue<ModelType>].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue<ModelType>].self) {
            self = .array(value)
        } else if container.decodeNil() {
            self = .null
        }
        else {
            throw DecodingError.typeMismatch(JSONValue<ModelType>.self,
                                             DecodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Invalid JSON"))
        }
    }
    
    public init(any value: Any?) {
        
        guard let parameterValue = value else {
            self = .null
            return 
        }
  
        switch parameterValue {
        case let foundValue as String:
            self = JSONValue<ModelType>(stringLiteral: foundValue)
            
        case let foundValue as Int64:
            self = JSONValue<ModelType>(int64: foundValue)
            
        case let foundValue as UInt:
            self = JSONValue<ModelType>(uint: foundValue)
            
        case let foundValue as Int:
            self = JSONValue<ModelType>(integerLiteral: foundValue)
            
        case let foundValue as Double:
            self = JSONValue<ModelType>(floatLiteral: foundValue)
        
        case let foundValue as Bool:
            self = JSONValue<ModelType>(booleanLiteral: foundValue)
            
        case let foundValue as Date:
            self = .date(foundValue)
            
        case let foundValue as [String: Any]:
            var newDict: [String: JSONValue<ModelType>] = [:]
            foundValue.keys.forEach { key in
                if let val = foundValue[key] {
                     newDict[key] = JSONValue<ModelType>(any: val)
                } else {
                    newDict[key] = .null
                }
            }
            self = .object(newDict)
    
        case let foundValue as [JSONValue<ModelType>]:
                self = .array(foundValue)
            
        case let foundValue as [Any]:
            self = .array(foundValue.map { JSONValue<ModelType>(any: $0) })
            
        case let foundValue as JSONValue:
            self = foundValue 
            
        default:
            self = .null

        }
        
    }
}

extension JSONValue {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        
        case .int64(let int64):
            try container.encode(int64)
            
        case .uint(let uint):
            try container.encode(uint)
            
        case .int(let int):
            try container.encode(int)
        
        case .double(let double):
            try container.encode(double)
        
        case .bool(let bool):
            try container.encode(bool)
            
        case .date(let datecontainer):
            try container.encode(datecontainer)
            
        case .object(let object):
            try container.encode(object)
        
        case .array(let array):
            try container.encode(array)
        
        case .null:
            try container.encodeNil()
        }
    }
}

extension JSONValue {
    func decode<T: Decodable>() throws -> T {
        let encoder = LibraryJSONEncoder()
        let encoded = try encoder.encode(self)
        let decoder = LibraryJSONDecoder()
        return try decoder.decode(T.self, from: encoded)
    }
}

extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = JSONValue<ModelType>.string(value)
    }
}

extension JSONValue {
    public init(int64 value: Int64) {
        self = JSONValue<ModelType>.int64(value)
    }
    
    public init(uint value: UInt) {
        self = JSONValue<ModelType>.uint(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = JSONValue<ModelType>.int(value)
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = JSONValue<ModelType>.double(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = JSONValue<ModelType>.bool(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValue...) {
        self = JSONValue<ModelType>.array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = JSONValue<ModelType>.object([String: JSONValue<ModelType>](uniqueKeysWithValues: elements))
    }
}

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = JSONValue.null
    }
}

extension JSONValue {
    public init(date: Date) {
        self = JSONValue.date(date)
    }
}

extension JSONValue {
    public func jsonString(file: StaticString =  #file, line: UInt = #line) -> String {
        do {
            switch self {
            case .null:
                return String(describing: NSNull())
            
            case .string(let string):
                return string
            
            case .int64(let int64):
                return String(int64)
                
            case .uint(let uint):
                return String(uint)
                
            case .int(let int):
                return String(int)
            
            case .double(let double):
                return String(double)
            
            case .bool(let bool):
                return String(bool)
                
            case .date(let d):
                return DateContainer(date: d).stringValue() ?? ""
                
            case .object, .array:
                let encoder = LibraryJSONEncoder()
                guard let value = try String(data: encoder.encode(self), encoding: .utf8) else {
                    fatalError("Error in data! String could not be parsed from data", file: file, line: line)
                }
                return value
            }
            
        } catch {
            fatalError("Error retrieving JSON string: \(error.localizedDescription)", file: file, line: line)
        }
    }
}
