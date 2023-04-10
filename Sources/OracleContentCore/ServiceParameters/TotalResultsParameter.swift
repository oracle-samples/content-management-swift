// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used by ``ImplementsTotalResults`` when determining whether or not to include `totalResults` in the response
public enum TotalResultsParameter: ConvertToURLQueryItem {
    case value(Bool)

    public static var keyValue: String {
        return "totalResults"
    }
    
    public var queryItem: URLQueryItem? {
        guard case TotalResultsParameter.value(let value) = self else {
            return nil
        }
        
        return URLQueryItem(name: TotalResultsParameter.keyValue, value: value ? "true" : "false")
    }
}
