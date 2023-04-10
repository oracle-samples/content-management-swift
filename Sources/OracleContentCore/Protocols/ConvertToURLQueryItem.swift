// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Items which provide query values for a web service will conform to this protocol - which allows for transformation into a `URLQueryItem` object.
public protocol ConvertToURLQueryItem {
    
    var queryItem: URLQueryItem? { get }
    
    /// Queries in a url have the form <key>=<value>. This property defines the key to be used
    static var keyValue: String { get }
}
