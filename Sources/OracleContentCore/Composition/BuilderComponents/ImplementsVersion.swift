// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public protocol ImplementsVersion: BaseImplementation {
    
    /// Specify the version of the API to use
    /// - parameter version: ManagementAPIVersion
    func version(_ version: APIVersion) -> ServiceReturnType
    
}

extension ImplementsVersion {
   public func version(_ version: APIVersion) -> ServiceReturnType {
        self.serviceParameters.apiVersion = version
        return self
    }
}
