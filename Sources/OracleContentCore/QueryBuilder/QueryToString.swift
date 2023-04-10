// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Protocol which defines the method which must be exposed on an object
/// used to build a search query
public protocol QueryToString {
    func buildQueryString() -> String
    
    var isValidQueryString: Bool { get }
}

extension QueryToString {
    
    public var isValidQueryString: Bool {
        return !self.buildQueryString().isEmpty
    }
}
