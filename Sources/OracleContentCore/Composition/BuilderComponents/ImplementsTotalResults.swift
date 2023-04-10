// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public protocol ImplementsTotalResults: BaseImplementation {

    /// Specify the version of the API to use
    /// - parameter version: ManagementAPIVersion
    func totalResults(_ value: Bool) -> Self
    
}

extension ImplementsTotalResults {
   public func totalResults(_ value: Bool) -> Self {
        self.serviceParameters.parameters[TotalResultsParameter.keyValue] = TotalResultsParameter.value(value)
        return self
    }
}
