// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
// swiftlint:disable cyclomatic_complexity

import Foundation

/**
 Protocol providing an implementation for access the custom fields of an object.
 
 The typical usage would be for an Asset model object to conform to this protocol.  Caller's could then access the custom fields of the asset by simply calling a convenience method of the appropriate type and passing in the name of the custom field.
 
 ```swift
 let boolValue: Bool = try asset.customField("field1")
 let stringValue: String = try asset.customField("field2")
 let assetValue: Asset = try asset.customField("field3")
 let arrayOfAssetsValues: [Asset] = try asset.customField("field4")
 let arrayOfStringValues: [String] = try asset.customField("field5")
 let dateValue: Date = try asset.customField("field6")
 
 let int64Value = try asset.customField("field7") as Int64
 
 ```
 */
public protocol ImplementsCustomFields {
    associatedtype AssetType: Codable, SupportsStringDescription
    
    var digitalAssetFields: EmbeddedDigitalAssetMetadata<AssetType>? { get set }
    var contentItemFields: [String: JSONValue<AssetType>]? { get set }
    
    func customField<T>(_ field: String) throws -> T
}

extension ImplementsCustomFields {
    
    /**
     Retrieves a custom field from an Asset. The field can be either a digital asset's custom field or any field from a content item.
     
     You must specify the type of data that is expected. You can do this by explicitly providing a type as part of a declaration:
     ```swift
    let x: String = try asset.customField("foo")
     ```
     
     or you can explicitly cast the result:
     ```swift
     let x = try asset.customField("foo") as String
     ```
     - parameter field: The name of the custom field
     - returns: An object of type T based on the type inference of the item requested.
     */
    public func customField<T>(_ field: String) throws -> T {
        switch T.self {
        case is String.Type :
        
            let value = try self.obtainField(field).first?.stringValue()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "String")
            }
            return returnValue
            
        case is Int.Type:
            let value = try self.obtainField(field).first?.intValue()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "Int")
            }
            
            return returnValue
            
        case is Int64.Type:
            let value = try self.obtainField(field).first?.int64Value()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "Int64")
            }
            return returnValue
            
        case is UInt.Type:
            let value = try self.obtainField(field).first?.uint()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "UInt")
            }
            return returnValue
            
        case is Double.Type:
            let value = try self.obtainField(field).first?.doubleValue()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "Double")
            }
            return returnValue
            
        case is Bool.Type:
            let value = try self.obtainField(field).first?.boolValue()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "Bool")
            }
            return returnValue
            
        case is Date.Type:
            let value = try self.obtainField(field).first?.dateValue()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "Date")
            }
            return returnValue
            
        case is [String: JSONValue<AssetType>].Type:
            let value = try self.obtainField(field).first?.objectValue()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "[String: JSONValue<AssetType>]")
            }
            return returnValue

        case is AssetType.Type:
            let value = try self.obtainField(field).first?.assetValue()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.couldNotParse(field, "AssetType")
            }
            return returnValue
            
        case is [AssetType].Type:
            let jsonValue = try self.obtainField(field).map { $0.arrayValue() }.compactMap { $0 }.flatMap { $0 }
            let parsedValue = jsonValue.compactMap { $0.assetValue() }
            guard let returnValue = parsedValue as? T else {
                throw JSONValueError.couldNotParse(field, "[AssetType]")
            }
            
            return returnValue
            
        case is [[String: JSONValue<AssetType>]].Type:
            let jsonValue = try self.obtainField(field).map { $0.arrayValue() }.compactMap { $0 }.flatMap { $0 }
            let parsedValue = jsonValue.compactMap { $0.objectValue() }
            guard let returnValue = parsedValue as? T else {
                throw JSONValueError.couldNotParse(field, "[[String: JSONValue<AssetType>]]")
            }
            
            return returnValue
            
        default:
            let value = try self.obtainField(field).first?.value()
            
            guard let returnValue = value as? T else {
                throw JSONValueError.unspecifiedFieldType(field)
            }
            return returnValue
        }
        
    }
    
    private func obtainField(_ field: String) throws -> [JSONValue<AssetType>] {
        if let digitalAssetFields = self.digitalAssetFields?.customFields {
            guard let fieldValue = digitalAssetFields[field] else {
                throw JSONValueError.fieldNotFound(field)
            }
            
            return [fieldValue]
            
        } else if let contentItemFields = self.contentItemFields {
            guard let fieldValue = contentItemFields[field] else {
                throw JSONValueError.fieldNotFound(field)
            }
            
            return [fieldValue]
        } else {
            throw JSONValueError.incompleteAsset
        }
    }
}
