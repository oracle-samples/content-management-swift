// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public protocol ImplementsExpand: BaseImplementation {

    /// Use this method to define the fields which should be expanded in web service results
    /// Default behavior, if this method is not called, is to expand "all" fields
    /// Note that you can specify mutliple values, however, if any of those values is "all", then "all" fields will be expanded
    func expand(_ value: FieldType) -> Self
    
    func expand(_ values: String...) -> Self
    
}

extension ImplementsExpand {
    
    /**
     The expand method provides the option of getting child resources (referenced items) inline with the item’s response. Field names are case-sensitive
     
     - parameter values: A collection of ``FieldType`` values
     */
    public func expand(_ value: FieldType) -> Self {
        let expandValues = ExpandValues(value)
        self.addParameter(key: ExpandValues.keyValue, value: expandValues)
        return self
    }
    
    /**
     The expand method provides the option of getting child resources (referenced items) inline with the item’s response. Field names are case-sensitive
     
     - parameter values: A collection of ``String`` values representing the field values to be expanded
     */
    public func expand(_ values: String...) -> Self {
        let valuesArray: [String] = Array(values)
        let expandValues = ExpandValues(valuesArray)
        self.addParameter(key: ExpandValues.keyValue, value: expandValues)
        return self
    }
}

public typealias ExpandParameter = [FieldType]

/**
 Defines the fields used as part of both the **expand** and **fields** query parameters. Allows for a more structure approach to specifying the fields. For example, instead of specifying "fields.field1", a caller would specify `.user("field1")`
 */
public enum FieldType: Hashable {
    case value(String)
    case all
    case none
    
    public func queryValue() -> String? {
        switch self {
        case .value(let value):
            return value
            
        case .all:
            return "all"
            
        case .none:
            return nil
        }
    }
    
    public init(_ stringValue: String) {
        switch stringValue.lowercased() {
        case "all":
            self = .all
            
        case "none":
            self = .none
            
        default:
            self = .value(stringValue)
        }
    }
}

public struct ExpandValues {
    private var values = ExpandParameter()
    
    public init(_ value: FieldType = .all ) {
        self.values = [value]
    }
    
    public init(_ values: [String] = []) {
        self.values = values.map { .value($0) }
    }
}

extension ExpandValues: ConvertToURLQueryItem {
    
    static public var keyValue: String {
        "expand"
    }
    
    public var queryItem: URLQueryItem? {
        
        var item: URLQueryItem?
        
        if self.containsAllValue() {
            item = URLQueryItem(name: ExpandValues.keyValue, value: FieldType.all.queryValue())
        } else if self.containsNoneValue() {
            item = nil
        } else {
            let stringValues = self.values.compactMap { $0.queryValue() }
            let separatedValues = stringValues.joined(separator: ",")
            
            if !separatedValues.isEmpty {
                item = URLQueryItem(name: "expand", value: separatedValues)
            }

        }
        
        return item
    }
    
}

// MARK: Privates
extension ExpandValues {
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
