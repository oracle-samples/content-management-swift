// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public protocol ImplementsLinks: BaseImplementation {

    associatedtype LinksValuesConstructor: AllowableFieldsValuesConstructor

    /// Limit the links to be returned to the listing of Strings provided
    /// - parameter links: [String] listing of the fields to be returned
    func links(_ links: LinksValuesConstructor.AllowableFieldTypes...) -> ServiceReturnType
}

extension ImplementsLinks {
    public func links(_ links: LinksValuesConstructor.AllowableFieldTypes...) -> ServiceReturnType {
        let linksValues = LinksValuesConstructor(links)
        self.addParameter(key: LinksValuesConstructor.keyValue, value: linksValues)
        return self
    }
}

public enum ListingLinkType: String {
    case selfLink = "self"
    case canonical
    case describedBy
    case first
    case last
    case prev
    case next
    
    internal func queryValue() -> String? {
        return self.rawValue
    }
}

public struct ListingLinksValues: AllowableFieldsValuesConstructor {
    public typealias ValueType = ListingLinkType
    
    private var values = [ValueType]()
    
    public init(_ values: [ValueType] ) {
        self.values = values
    }
}

extension ListingLinksValues: ConvertToURLQueryItem {
    
    static public var keyValue: String {
        "links"
    }
    
    public var queryItem: URLQueryItem? {
        
        var returnValue: URLQueryItem?
        
        if !self.values.isEmpty {
            let linkValues = self.values.compactMap { $0.queryValue() }
            let linksQueryItem = URLQueryItem(name: ListingLinksValues.keyValue, value: linkValues.joined(separator: ","))
            returnValue = linksQueryItem
        }
        
        return returnValue
    }
}

public enum ReadLinkType: String {
    case selfLink = "self"
    case canonical
    case describedBy
}

public struct ReadLinksValues: AllowableFieldsValuesConstructor {
    
    public typealias ValueType = ReadLinkType
    
    private var values = [ValueType]()
    
    public init(_ values: [ValueType] ) {
        self.values = values
    }
}

extension ReadLinksValues: ConvertToURLQueryItem {
    
    static public var keyValue: String {
        "links"
    }
    
    public var queryItem: URLQueryItem? {
        
        var returnValue: URLQueryItem?
        
        if !self.values.isEmpty {
            let linkValues = self.values.compactMap { $0.rawValue }
            let linksQueryItem = URLQueryItem(name: ListingLinksValues.keyValue, value: linkValues.joined(separator: ","))
            returnValue = linksQueryItem
        }
        
        return returnValue
    }
}
