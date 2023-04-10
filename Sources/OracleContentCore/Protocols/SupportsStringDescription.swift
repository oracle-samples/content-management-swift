// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Protocol which, when adopted, exposes a stringDescription method
public protocol SupportsStringDescription {
    func stringDescription() -> String
}
