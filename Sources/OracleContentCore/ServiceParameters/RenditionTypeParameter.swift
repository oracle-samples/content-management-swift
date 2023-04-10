// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used by download services  to track the rendition type
public enum RenditionTypeParameter {
    
    case value(String)
}

extension RenditionTypeParameter: ConvertToURLQueryItem {
    public static var keyValue: String {
        return "type"
    }

    public var queryItem: URLQueryItem? {
        guard case RenditionTypeParameter.value(let value) = self else {
            return nil
        }
        
        return URLQueryItem(name: RenditionTypeParameter.keyValue, value: value)
    }
}
