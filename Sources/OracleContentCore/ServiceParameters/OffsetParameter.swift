// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used to populate the offset parameter when performing listing operations
public enum OffsetParameter: ConvertToURLQueryItem {
    
    case value(UInt)
    
    public static var keyValue: String {
        return "offset"
    }
    
    public var queryItem: URLQueryItem? {
        guard case OffsetParameter.value(let numericOffset) = self else {
            return nil
        }
        
        return URLQueryItem(name: OffsetParameter.keyValue, value: String(numericOffset))
        
    }
    
}
