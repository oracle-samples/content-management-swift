// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used to populate the limit parameter when fetching a listing of objects
public enum LimitParameter: ConvertToURLQueryItem {
    
    case value(UInt)
    
    public static var keyValue: String {
        return "limit"
    }
    
    public var queryItem: URLQueryItem? {
        guard case LimitParameter.value(let numericOffset) = self else {
            return nil
        }
        
        return URLQueryItem(name: LimitParameter.keyValue, value: String(numericOffset))
        
    }
    
}
