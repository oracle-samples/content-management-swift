// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Objects conforming to SupportsEmptyIntializer implement a required initializer that initializes all properties to their default values.
/// Primarily useful in testing situations
public protocol SupportsEmptyInitializer {
    init()
}
