// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Provide the channel token for web service calls. Used as part of the ``ImplementsChannelToken`` compositional element
public enum ChannelTokenParameter {
    case value(String)
    
    init(_ value: String) {
        self = .value(value)
    }
    
    func queryValue() -> String? {
        
        switch self {
        case .value(let token):
            return token
        }
    }
}

extension ChannelTokenParameter: ConvertToURLQueryItem {
    
    public static var keyValue: String {
        "channelToken"
    }
    
    public var queryItem: URLQueryItem? {
        guard let queryValue = self.queryValue() else {
            return nil
        }
        
        let fieldsItem = URLQueryItem(name: ChannelTokenParameter.keyValue, value: queryValue)
        return fieldsItem
    }
}
