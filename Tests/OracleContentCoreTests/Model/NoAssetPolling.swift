// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

public struct NoAssetPolling<Element>: Codable, SupportsStringDescription, SupportsPolling {
    
    public func isComplete() -> Bool {
        return false
    }
    
    public func stringDescription() -> String {
        return "<unused>"
    }
}
