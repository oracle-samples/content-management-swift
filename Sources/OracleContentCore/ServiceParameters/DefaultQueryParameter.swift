// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public enum DefaultQueryType {
    case value(String)
    
    init(_ value: String) {
        self = .value(value)
    }
    
    func queryValue() -> String? {
        
        switch self {
        case .value(let value):
            return value 
        }
    }
}

public struct DefaultQueryValues {
    
    private var values = [DefaultQueryType]()
    
    public init(_ values: [String]) {
        self.values = values.map { DefaultQueryType($0) }
    }
}

extension DefaultQueryValues: ConvertToURLQueryItem {
    
    static public var keyValue: String {
        "default"
    }
    
    public var queryItem: URLQueryItem? {
        
        var returnValue: URLQueryItem?
        
        if !self.values.isEmpty {
            let urlEncodedLinks = self.values.compactMap { $0.queryValue() }
            
            // NOTE: separator is <comma> plus <space> to try and alleviate some problematic server behavior
            // when numeric values are separated by a comma
            let linksItem = URLQueryItem(name: DefaultQueryValues.keyValue, value: urlEncodedLinks.joined(separator: ", "))
            returnValue = linksItem
        }
        
        return returnValue
    }
}
