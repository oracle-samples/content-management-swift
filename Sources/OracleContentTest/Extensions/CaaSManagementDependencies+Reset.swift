// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

extension Onboarding {
    
    /// Reset any override that may have been performed
    static func reset() {
        Onboarding.sessions = OracleContentSessionProvider()
    }
}
