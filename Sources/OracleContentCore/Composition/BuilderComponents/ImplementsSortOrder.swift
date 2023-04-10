// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
Protocol implementing composition-based sort order of web service responses.
 
 */
public protocol ImplementsSortOrder: BaseImplementation {
    /**
     The orderBy parameter is used to control the order (ascending/descending) of queried items.
     
     This parameter is optional in the query and by default there is no order of results.
     
     Any incorrect or invalid field name given in the query will be ignored.
     
     Swift Usage Example:
     ```swift
     let service = ManagementAPI.listAssets().order(.standard("name", .asc))
     ```
     `
     - parameter sortOrders: The array of sort orders for the web service call.
     */
    
    associatedtype SortOrderValuesConstructor: AllowableFieldsValuesConstructor
    
    func order(_ values: SortOrderValuesConstructor.AllowableFieldTypes...) -> ServiceReturnType
    
}

extension ImplementsSortOrder {
     public func order(_ values: SortOrderValuesConstructor.AllowableFieldTypes...) -> ServiceReturnType {
         let value = SortOrderValuesConstructor(values)
         self.addParameter(key: SortOrderValuesConstructor.keyValue, value: value)
         return self
    }
}

public struct SortOrderValues<ValueType: SupportsQueryValue>: AllowableFieldsValuesConstructor {
    private var values = [ValueType]()
    
    public init(_ values: [ValueType] = [] ) {
        self.values = values
    }
    
    static public var keyValue: String {
           "orderBy"
       }
       
   public var queryItem: URLQueryItem? {
       
       var item: URLQueryItem?
        
       let stringValues = self.values.compactMap { $0.queryValue() }
       let separatedValues = stringValues.joined(separator: ";")
       
       if !separatedValues.isEmpty {
           item = URLQueryItem(name: SortOrderValues.keyValue, value: separatedValues)
       }

       return item
   }
}

/**
 In a type-specific query, field names can be either:
 
 * standard fields (name, createdDate, updatedDate) or
 * user-defined fields (single-valued data types (number, decimal, datetime)).
 
 In case of a query across types, only name, createdDate and updatedDate (Standard fields) are allowed.
 */
public enum AssetsSortOrderType: SupportsQueryValue {

    case field(String, SortOrder)
    
    public func queryValue() -> String? {
        switch self {
        case let .field(fieldName, order):
            return "\(fieldName):\(order.rawValue)"
        }
    }
}

/**
 Sort order for calls to listWorkflowTasks
 Available options are name, dueDate and workflow.name
 */
public enum WorkflowTasksOrderType: SupportsQueryValue {
    case name(SortOrder)
    case dueDate(SortOrder)
    case workflowName(SortOrder)
    case field(String, SortOrder)
    
    public func queryValue() -> String? {
        switch self {
        case let .name(order):
            return "name:\(order.rawValue)"
            
        case let .dueDate(order):
            return "dueDate:\(order.rawValue)"
            
        case let .workflowName(order):
            return "workflow.name:\(order.rawValue)"
            
        case let .field(fieldName, order):
            return "\(fieldName):\(order.rawValue)"
        }
    }
}

/**
 Limited sort order - allowing only name and updated date

 */
public enum LimitedSortOrderType: SupportsQueryValue {
    case name(SortOrder)
    case updatedDate(SortOrder)
    
    public func queryValue() -> String? {
        switch self {
        case .name(let order):
            return "name:\(order.rawValue)"
            
        case .updatedDate(let order):
            return "updatedDate:\(order.rawValue)"
        }
    }
}

/**
 Taxonomy sort order - allowing only name, createdDate and updateDate
 
 */
public enum TaxomomySortOrderType: SupportsQueryValue {
    case name(SortOrder)
    case createdDate(SortOrder)
    case updatedDate(SortOrder)
    
    public func queryValue() -> String? {
        switch self {
            
        case let .name(order):
            return "name:\(order.rawValue)"
            
        case let.createdDate(order):
            return "createdDate:\(order.rawValue)"
            
        case let .updatedDate(order):
            return "updatedDate:\(order.rawValue)"
        }
    }
}

/**
 Taxonomy sort order - allowing only name and position
 
 */
public enum TaxomomyCategorySortOrderType: SupportsQueryValue {
    case name(SortOrder)
    case position(SortOrder)
    
    public func queryValue() -> String? {
        switch self {
            
        case let .name(order):
            return "name:\(order.rawValue)"
            
        case let.position(order):
            return "position:\(order.rawValue)"

        }
    }
}

