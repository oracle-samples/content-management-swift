// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// The compositional protocols for ordering (ImplementsSortOrder and ImplementsLimitedSortOrder) reference this protocol in order to provide support for their respective enums.
public protocol SupportsQueryValue {
    
    /// Allows a web service to transform its ``ServiceParameters`` object into a string that may be used as the query for a web service
    func queryValue() -> String?
}
