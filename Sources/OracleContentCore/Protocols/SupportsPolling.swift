// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// When a web service conforms to `SupportsPolling` it must provide exit criteria to define when polling should cease
public protocol SupportsPolling {
    associatedtype Element
    
    /// Should return true when conditions have been satifisfied to cease polling
    func isComplete() -> Bool
}

