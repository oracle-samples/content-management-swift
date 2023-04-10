// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used by download service to track the rendition format
public enum RenditionFormatParameter {
    
    case value(String)
}

extension RenditionFormatParameter: ConvertToURLQueryItem {
    public static var keyValue: String {
        return "format"
    }
    
    public var queryItem: URLQueryItem? {
        guard case RenditionFormatParameter.value(let value) = self else {
            return nil
        }
        
        return URLQueryItem(name: RenditionFormatParameter.keyValue, value: value)
    }
}
