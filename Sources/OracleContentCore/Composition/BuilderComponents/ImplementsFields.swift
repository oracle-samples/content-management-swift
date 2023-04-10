// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
 Protocol which defines an initializer of a generic type of field values. Services can support various allowable field values so this protocol provides a common initializer of ``AllowableFieldTypes`` values.
 */
public protocol AllowableFieldsValuesConstructor: ConvertToURLQueryItem {
    associatedtype AllowableFieldTypes
    
    init(_ values: [AllowableFieldTypes])
}

/**
 A service conforming to `ImplementsFields` will be able to provide field definitions that should be included in the service response.
 */
public protocol ImplementsFields: BaseImplementation {

    /**
     The associatedtype `FieldValuesConstructor` represents the type of fields that are allowed. For example, some services that conform to `ImplementsFields` support one set of allowable values while other services support a different set entirely. Specifying the associatedtype allows for a generic method that can be used to support many different services.
     */

    associatedtype FieldValuesConstructor: AllowableFieldsValuesConstructor
 
    /**
     Function that allows the conforming service to specify the fields that should be included in responses. The allowable values will differ based on the conforming web service.
     
     - parameter values: An array of `FieldValuesConstructor.AllowableFieldTypes`
     - returns: `ServiceReturnType`
     */
    func fields(_ values: FieldValuesConstructor.AllowableFieldTypes...) -> ServiceReturnType
    
}

extension ImplementsFields {
    
    public func fields(_ values: FieldValuesConstructor.AllowableFieldTypes...) -> ServiceReturnType {
        let value = FieldValuesConstructor(values)
        self.addParameter(key: FieldValuesConstructor.keyValue, value: value)
        return self
   }
}

/**
The FieldValues structure is reponsible for turning the specified fields into a query that may be used as part of a web service. The query will be of the form, `fields=<values>`.
*/
public struct FieldValues: AllowableFieldsValuesConstructor {
    
    public typealias ValueType = FieldType
    
    private var values = [ValueType]()
    
    public init(_ values: [FieldType] = [] ) {
        self.values = values
    }
}

extension FieldValues: ConvertToURLQueryItem {
    
    static public var keyValue: String {
        "fields"
    }
    
    public var queryItem: URLQueryItem? {
        
        var item: URLQueryItem?
        
        if self.containsAllValue() {
            item = URLQueryItem(name: FieldValues.keyValue, value: FieldType.all.queryValue())
        } else if self.containsNoneValue() {
            item = nil
        } else {
            let stringValues = self.values.compactMap { $0.queryValue() }
            let separatedValues = stringValues.joined(separator: ",")
            
            if !separatedValues.isEmpty {
                item = URLQueryItem(name: FieldValues.keyValue, value: separatedValues)
            }

        }
        
        return item
    }
    
}

extension FieldValues {
    private func containsAllValue() -> Bool {
        return self.values.contains { element in
            if case .all = element {
                return true
            }
            return false
        }
    }
    
    private func containsNoneValue() -> Bool {
        return self.values.contains { element in
            if case .none = element {
                return true
            }
            return false
        }
    }
}

