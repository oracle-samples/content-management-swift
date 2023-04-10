// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

internal enum CoreBundleHelper {
    
    @inline(__always)
    static func bundle(for aClass: AnyClass) -> Bundle {
        
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: aClass)
        #endif
    }
}
