// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used by ``ImplementsIsPublishedChannel`` to populate the query
public enum PublishedChannelParameter {
    
    case value(Bool)
}

extension PublishedChannelParameter: ConvertToURLQueryItem {
    public static var keyValue: String {
        return "isPublishedChannel"
    }
    
    public var queryItem: URLQueryItem? {
        guard case PublishedChannelParameter.value(let value) = self else {
            return nil
        }
        
        return URLQueryItem(name: PublishedChannelParameter.keyValue, value: value ? "true" : "false")
    }
}
