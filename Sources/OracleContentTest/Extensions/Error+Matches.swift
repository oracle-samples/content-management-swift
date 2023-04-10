// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

extension Error {

    public func matchesError(_ otherError: Error?) -> Bool {

        if let otherError = otherError {

            // Need to use the NSError bridged form to get to the properties
            let selfNSError = self as NSError
            let otherNSError = otherError as NSError

            return otherNSError.domain == selfNSError.domain && otherNSError.code == selfNSError.code
        }

        return false
    }

}
 
